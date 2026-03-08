# Fieldnotes — Пошаговый TDD-план разработки

---

## Архитектура одной строкой

Монолитное Rails 8.1 приложение — личный сайт (эссе, проекты, книги, фото-экспедиции, /now). SQLite в продакшене, Solid Queue/Cache/Cable, Lexxy-редактор, AVIF-пайплайн. Два слоя контроллеров: `Public::` (читатели) и `Admin::` (автор). Zero JS-фреймворков — только Stimulus.

## Текущее состояние

Голый скелет Rails 8.1: есть Gemfile, конфиги, CI-пайплайн, документация. **Нет ни одной миграции, модели, контроллера, вью или теста.** Всё пишем с нуля.

---

## Порядок разработки

```
1. Auth (User/Session)
2. Models (Essay → NowEntry → Build → Book → FieldSeries/FieldItem → Tag/Tagging → PageView)
3. Services (OpenLibraryService)
4. Jobs (ImageVariantJob, ExportJob)
5. Controllers — Admin (CRUD)
6. Controllers — Public (read-only + RSS/MD)
7. ERB partials + helpers (meta tags, cards, picture_tag)
8. ~~System tests~~ — не используем (контроллерные тесты достаточны)
```

---

## Этап 1: Аутентификация

**Что делаем:** генерируем Rails 8 built-in auth, добавляем `Admin::BaseController` с защитой.

**Red — тесты первыми:**

```ruby
# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(email_address: "admin@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(email_address: nil, password: "password123")
    assert_not user.valid?
  end

  test "email must be unique" do
    User.create!(email_address: "admin@example.com", password: "password123", password_confirmation: "password123")
    duplicate = User.new(email_address: "admin@example.com", password: "password123", password_confirmation: "password123")
    assert_not duplicate.valid?
  end
end
```

```ruby
# test/controllers/admin/base_controller_test.rb
class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated user to login" do
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "allows authenticated user" do
    sign_in_as users(:admin)
    get admin_root_url
    assert_response :success
  end
end
```

**Green:**
- `bin/rails generate authentication`
- Создать `Admin::BaseController` с `before_action :require_authentication`
- Фикстура `test/fixtures/users.yml`
- Хелпер `sign_in_as` в `test_helper.rb`

**Refactor:** извлечь `sign_in_as` в `ActionDispatch::IntegrationTest` как shared helper.

**Готово когда:** `bin/rails test test/models/user_test.rb test/controllers/admin/base_controller_test.rb` — зелёные.

---

## Этап 2: Модель Essay (ядро)

**Что делаем:** миграция + модель Essay со всеми валидациями, скоупами, слагами.

**Red:**

```ruby
# test/models/essay_test.rb
class EssayTest < ActiveSupport::TestCase
  # --- Валидации ---
  test "valid with all required attributes" do
    essay = Essay.new(title: "Test Essay", slug: "test-essay", status: "draft")
    assert essay.valid?
  end

  test "invalid without title" do
    essay = Essay.new(slug: "test", status: "draft")
    assert_not essay.valid?
    assert_includes essay.errors[:title], "can't be blank"
  end

  test "invalid without slug" do
    essay = Essay.new(title: "Test", status: "draft")
    assert_not essay.valid?
  end

  test "slug must be unique" do
    Essay.create!(title: "First", slug: "same-slug", status: "draft")
    duplicate = Essay.new(title: "Second", slug: "same-slug", status: "draft")
    assert_not duplicate.valid?
  end

  test "slug format allows only lowercase letters, numbers, hyphens" do
    essay = Essay.new(title: "Test", slug: "INVALID SLUG!", status: "draft")
    assert_not essay.valid?
  end

  test "status must be draft or published" do
    essay = Essay.new(title: "Test", slug: "test", status: "archived")
    assert_not essay.valid?
  end

  # --- Скоупы ---
  test "published scope returns only published essays ordered by published_at desc" do
    old = essays(:published_old)
    new_essay = essays(:published_new)
    _draft = essays(:draft)

    result = Essay.published
    assert_includes result, new_essay
    assert_includes result, old
    assert_not_includes result, _draft
    assert_equal new_essay, result.first
  end

  test "drafts scope returns only draft essays" do
    assert Essay.drafts.all? { it.status == "draft" }
  end

  # --- Методы ---
  test "published? returns true for published status" do
    essay = Essay.new(status: "published")
    assert essay.published?
  end

  test "draft? returns true for draft status" do
    essay = Essay.new(status: "draft")
    assert essay.draft?
  end
end
```

**Green:**
- Миграция: `title, slug, excerpt, status, published_at, latitude, longitude, location_name`
- Модель: `has_rich_text :content`, `has_one_attached :cover`
- Валидации: presence, uniqueness, inclusion, format
- Скоупы: `published`, `drafts`
- Фикстуры: `test/fixtures/essays.yml` (draft, published_old, published_new)

**Refactor:** извлечь `Sluggable` concern (понадобится для Build, FieldSeries).

**Готово когда:** `bin/rails test test/models/essay_test.rb` — зелёные.

---

## Этап 3: Модель NowEntry

**Что делаем:** NowEntry с rich text. Каждое обновление — новая запись; история = все записи, отсортированные по `published_at desc`. Никакого paper_trail.

**Red:**

```ruby
# test/models/now_entry_test.rb
class NowEntryTest < ActiveSupport::TestCase
  test "valid with published_at" do
    entry = NowEntry.new(published_at: Time.current)
    assert entry.valid?
  end

  test "invalid without published_at" do
    entry = NowEntry.new
    assert_not entry.valid?
  end

  test "has rich text body" do
    entry = now_entries(:current)
    assert_respond_to entry, :body
  end

  test "latest scope returns most recent entry" do
    assert_equal now_entries(:current), NowEntry.latest
  end

  test "previous scope returns older entries ordered by published_at desc" do
    result = NowEntry.previous
    assert_not_includes result, now_entries(:current)
    assert result.all? { it.published_at < now_entries(:current).published_at }
  end
end
```

**Green:**
- Миграция: `now_entries` (published_at)
- Модель: `has_rich_text :body`, scope `latest`, scope `previous`
- Фикстуры: `now_entries.yml` (current + older)

**Refactor:** —

---

## Этап 4: Модель Build

**Что делаем:** Build — карточный каталог проектов.

**Red:**

```ruby
# test/models/build_test.rb
class BuildTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    build = Build.new(title: "My Project", slug: "my-project", status: "active", kind: "oss")
    assert build.valid?
  end

  test "invalid without title" do
    build = Build.new(slug: "test", status: "active", kind: "oss")
    assert_not build.valid?
  end

  test "status must be in allowed list" do
    build = Build.new(title: "X", slug: "x", kind: "oss", status: "invalid")
    assert_not build.valid?
  end

  test "kind must be in allowed list" do
    build = Build.new(title: "X", slug: "x", status: "active", kind: "invalid")
    assert_not build.valid?
  end

  test "ordered scope returns by position" do
    first = builds(:first_position)
    second = builds(:second_position)
    assert_equal [first, second], Build.ordered.to_a
  end

  test "active scope excludes archived" do
    assert Build.active.none? { it.status == "archived" }
  end
end
```

**Green:**
- Миграция: `title, slug, description, url, icon_emoji, status, kind, position, started_on, finished_on`
- Модель: валидации, `has_one_attached :cover`, скоупы `ordered`, `active`
- Использовать `Sluggable` concern из этапа 2

---

## Этап 5: Модель Book

**Что делаем:** Book — лог чтения с ключевой идеей.

**Red:**

```ruby
# test/models/book_test.rb
class BookTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    book = Book.new(title: "Clean Code", author: "Robert Martin", status: "completed")
    assert book.valid?
  end

  test "rating between 1 and 5" do
    book = Book.new(title: "X", author: "Y", status: "completed", rating: 6)
    assert_not book.valid?
  end

  test "rating can be nil" do
    book = Book.new(title: "X", author: "Y", status: "reading", rating: nil)
    assert book.valid?
  end

  test "status must be reading, completed, or abandoned" do
    book = Book.new(title: "X", author: "Y", status: "wishlist")
    assert_not book.valid?
  end

  test "completed scope returns only completed books" do
    assert Book.completed.all? { it.status == "completed" }
  end

  test "by_year scope groups by year_read desc" do
    books = Book.by_year
    years = books.map(&:year_read).compact
    assert_equal years, years.sort.reverse
  end
end
```

**Green:**
- Миграция: `title, author, cover_url, year_read, rating, key_idea, status`
- Модель: валидации, скоупы `completed`, `by_year`

---

## Этап 6: Модели FieldSeries + FieldItem

**Что делаем:** экспедиции (серии фото/видео) с вложенными элементами.

**Red:**

```ruby
# test/models/field_series_test.rb
class FieldSeriesTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    series = FieldSeries.new(title: "Iceland 2026", slug: "iceland-2026", kind: "photo")
    assert series.valid?
  end

  test "kind must be photo, video, or mixed" do
    series = FieldSeries.new(title: "X", slug: "x", kind: "audio")
    assert_not series.valid?
  end

  test "has many field_items" do
    series = field_series(:iceland)
    assert series.field_items.any?
  end

  test "destroying series destroys items" do
    series = field_series(:iceland)
    item_count = series.field_items.count
    assert_difference("FieldItem.count", -item_count) { series.destroy }
  end
end

# test/models/field_item_test.rb
class FieldItemTest < ActiveSupport::TestCase
  test "valid photo item" do
    item = FieldItem.new(field_series: field_series(:iceland), kind: "photo", position: 1)
    assert item.valid?
  end

  test "video item requires youtube_url" do
    item = FieldItem.new(field_series: field_series(:iceland), kind: "video", position: 1, youtube_url: nil)
    assert_not item.valid?
  end

  test "ordered scope sorts by position" do
    items = FieldItem.ordered
    positions = items.map(&:position)
    assert_equal positions, positions.sort
  end
end
```

**Green:**
- Миграции: `field_series`, `field_items` (с FK)
- Модели: ассоциации, `has_one_attached :photo` на FieldItem, `Sluggable` concern
- `dependent: :destroy` на has_many

---

## Этап 7: Tag / Tagging (полиморфная)

**Что делаем:** полиморфные теги для essays, builds, field_series.

**Red:**

```ruby
# test/models/tag_test.rb
class TagTest < ActiveSupport::TestCase
  test "valid with name" do
    tag = Tag.new(name: "ruby")
    assert tag.valid?
  end

  test "name must be unique" do
    Tag.create!(name: "ruby")
    assert_not Tag.new(name: "ruby").valid?
  end

  test "essay can have tags" do
    essay = essays(:published_new)
    tag = tags(:ruby)
    essay.tags << tag
    assert_includes essay.tags, tag
  end

  test "tag can belong to multiple taggables" do
    tag = tags(:ruby)
    assert tag.taggings.count >= 0
  end
end
```

**Green:**
- Миграции: `tags` (name), `taggings` (tag_id, taggable_id, taggable_type)
- Модели: `Tag`, `Tagging`, полиморфные `has_many :through`
- Concern `Taggable` → включить в Essay, Build, FieldSeries

---

## Этап 8: PageView (аналитика)

**Что делаем:** серверная аналитика через `Rails.event.notify`.

**Red:**

```ruby
# test/models/page_view_test.rb
class PageViewTest < ActiveSupport::TestCase
  test "valid with event name" do
    pv = PageView.new(event: "essay.viewed", payload: { essay_id: 1 })
    assert pv.valid?
  end

  test "invalid without event" do
    pv = PageView.new(payload: { essay_id: 1 })
    assert_not pv.valid?
  end

  test "payload stores JSON" do
    pv = PageView.create!(event: "essay.viewed", payload: { essay_id: 42, path: "/essays/test" })
    assert_equal 42, pv.reload.payload["essay_id"]
  end
end
```

```ruby
# test/subscribers/analytics_subscriber_test.rb
class AnalyticsSubscriberTest < ActiveSupport::TestCase
  test "creates page_view on essay.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("essay.viewed", essay_id: 1, path: "/essays/test")
    end
  end
end
```

**Green:**
- Миграция: `page_views` (event:string, payload:json, created_at)
- Модель: валидация presence event
- Инициализатор: `config/initializers/analytics.rb` с подпиской на события

---

## Этап 9: OpenLibraryService

**Что делаем:** сервис для получения обложек и метаданных книг по ISBN.

**Red:**

```ruby
# test/services/open_library_service_test.rb
class OpenLibraryServiceTest < ActiveSupport::TestCase
  test "fetch returns hash with title, author, cover_url, year" do
    # Stub HTTP call
    stub_open_library_api("9780134757599")

    result = OpenLibraryService.fetch(isbn: "9780134757599")

    assert_equal "Refactoring", result[:title]
    assert result[:cover_url].present?
  end

  test "returns nil on API failure" do
    stub_open_library_api_failure("0000000000")

    result = OpenLibraryService.fetch(isbn: "0000000000")
    assert_nil result
  end

  test "caches results for 7 days" do
    stub_open_library_api("9780134757599")

    OpenLibraryService.fetch(isbn: "9780134757599")

    # Second call should hit cache, not HTTP
    assert_no_http_requests do
      OpenLibraryService.fetch(isbn: "9780134757599")
    end
  end
end
```

**Green:**
- `app/services/open_library_service.rb`
- `Rails.cache.fetch("open_library:#{isbn}", expires_in: 7.days)`
- HTTP через `Net::HTTP` (без дополнительных гемов)
- Graceful fallback: rescue → nil

**Refactor:** извлечь HTTP-обёртку если нужна ещё для PulseJob (v2).

---

## Этап 10: ImageVariantJob

**Что делаем:** фоновая генерация вариантов изображений после загрузки.

**Red:**

```ruby
# test/jobs/image_variant_job_test.rb
class ImageVariantJobTest < ActiveSupport::TestCase
  test "generates all variants for essay cover" do
    essay = essays(:with_cover)

    assert_nothing_raised do
      ImageVariantJob.perform_now(essay.cover)
    end

    assert essay.cover.variant(:thumb).processed?
    assert essay.cover.variant(:medium).processed?
    assert essay.cover.variant(:full).processed?
  end

  test "generates watermarked variants for field_item photo" do
    item = field_items(:photo_one)

    ImageVariantJob.perform_now(item.photo, watermark: true)

    assert item.photo.variant(:full).processed?
  end

  test "does not raise on missing attachment" do
    assert_nothing_raised do
      ImageVariantJob.perform_now(nil)
    end
  end
end
```

**Green:**
- `app/jobs/image_variant_job.rb`
- Варианты: thumb (400x300), medium (800x600), full (1920x1080), hero (1600x900)
- Формат AVIF, quality по спецификации
- Опциональный watermark для field photos
- `after_create_commit` callback на моделях с attachments → enqueue job

---

## Этап 11: ExportJob (ActiveJob::Continuable)

**Что делаем:** многошаговый экспорт всех данных в ZIP.

**Red:**

```ruby
# test/jobs/export_job_test.rb
class ExportJobTest < ActiveSupport::TestCase
  test "creates ZIP with correct structure" do
    ExportJob.perform_now

    # Verify ZIP was attached and contains expected files
    export = Export.last
    assert export.archive.attached?

    Zip::File.open(ActiveStorage::Blob.service.path_for(export.archive.key)) do |zip|
      assert zip.find_entry("data/essays.json")
      assert zip.find_entry("data/books.json")
      assert zip.find_entry("data/builds.json")
      assert zip.find_entry("data/now_entries.json")
      assert zip.find_entry("README.md")
    end
  end

  test "export expires after 24 hours" do
    ExportJob.perform_now
    export = Export.last
    assert_in_delta 24.hours.from_now, export.expires_at, 1.minute
  end

  test "prevents concurrent exports" do
    ExportJob.perform_now
    assert_no_enqueued_jobs(only: ExportJob) do
      ExportJob.perform_later
    end
  end
end
```

**Green:**
- `app/jobs/export_job.rb` с `ActiveJob::Continuable`
- Steps: `export_data`, `export_files`, `build_zip`, `notify`
- Модель `Export` с `has_one_attached :archive`, `expires_at`
- Добавить `gem "rubyzip"` в Gemfile

---

## Этап 12: Admin контроллеры

**Что делаем:** CRUD для всех моделей в admin namespace.

**Red:**

```ruby
# test/controllers/admin/essays_controller_test.rb
class Admin::EssaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:admin)
  end

  test "index lists all essays" do
    get admin_essays_url
    assert_response :success
  end

  test "new renders form" do
    get new_admin_essay_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Essay.count", 1) do
      post admin_essays_url, params: { essay: { title: "New Essay", slug: "new-essay", status: "draft" } }
    end
    assert_redirected_to admin_essay_url(Essay.last)
  end

  test "create with invalid params renders form with 422" do
    post admin_essays_url, params: { essay: { title: "", slug: "" } }
    assert_response :unprocessable_entity
  end

  test "update changes essay" do
    essay = essays(:draft)
    patch admin_essay_url(essay), params: { essay: { title: "Updated" } }
    assert_redirected_to admin_essay_url(essay)
    assert_equal "Updated", essay.reload.title
  end

  test "destroy removes essay" do
    essay = essays(:draft)
    assert_difference("Essay.count", -1) { delete admin_essay_url(essay) }
    assert_redirected_to admin_essays_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get admin_essays_url
    assert_redirected_to new_session_url
  end
end
```

Аналогичные тесты для:
- `Admin::BuildsControllerTest`
- `Admin::BooksControllerTest`
- `Admin::FieldControllerTest` + `Admin::FieldItemsControllerTest`
- `Admin::NowControllerTest` (только edit/update)

**Green:**
- `Admin::BaseController < ApplicationController` с `before_action :require_authentication`
- CRUD контроллеры наследуют от `Admin::BaseController`
- Routes: `namespace :admin { ... }` по спецификации из CLAUDE.md
- Admin views: формы с Lexxy-редактором для rich text

**Refactor:** извлечь общую логику set_resource в concern если повторяется.

---

## Этап 13: Public контроллеры

**Что делаем:** публичные read-only контроллеры с RSS, Markdown, rate_limit, fresh_when.

**Red:**

```ruby
# test/controllers/public/essays_controller_test.rb
class Public::EssaysControllerTest < ActionDispatch::IntegrationTest
  test "index shows published essays only" do
    get essays_url
    assert_response :success
    assert_select "article", count: Essay.published.count
  end

  test "index does not show drafts" do
    get essays_url
    assert_no_match essays(:draft).title, response.body
  end

  test "show renders published essay" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug)
    assert_response :success
  end

  test "show returns 404 for draft" do
    get essay_url(slug: essays(:draft).slug)
    assert_response :not_found
  end

  test "show.rss returns RSS format" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug, format: :rss)
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end

  test "show.md returns markdown" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug, format: :md)
    assert_response :success
    assert_equal "text/markdown", response.media_type
  end

  test "emits essay.viewed event" do
    essay = essays(:published_new)
    assert_difference("PageView.count", 1) do
      get essay_url(slug: essay.slug)
    end
  end

  test "returns 304 when not modified" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug)
    etag = response.headers["ETag"]

    get essay_url(slug: essay.slug), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end

# test/controllers/public/feed_controller_test.rb
class Public::FeedControllerTest < ActionDispatch::IntegrationTest
  test "index renders homepage" do
    get root_url
    assert_response :success
  end

  test "index.rss returns unified RSS feed" do
    get feed_url(format: :rss)
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end
end

# test/controllers/public/now_controller_test.rb
class Public::NowControllerTest < ActionDispatch::IntegrationTest
  test "show renders latest now entry" do
    get now_url
    assert_response :success
  end

  test "show displays previous entries" do
    get now_url
    assert_select ".previous-entries"
  end
end
```

Аналогичные тесты для `Public::BuildsController`, `Public::BooksController`, `Public::FieldController`, `Public::PagesController`.

**Green:**
- Контроллеры в `scope module: :public` по спецификации routes
- `fresh_when` на show/index
- `rate_limit to: 60, within: 1.minute` на index
- `respond_to` для .rss и .md форматов
- `Rails.event.notify` для аналитики
- Только published контент в публичных скоупах

---

## Этап 14: Sitemap + RSS

**Что делаем:** XML-карта сайта и полнотекстовые RSS-фиды.

**Red:**

```ruby
# test/controllers/sitemap_controller_test.rb
class SitemapControllerTest < ActionDispatch::IntegrationTest
  test "returns valid XML" do
    get sitemap_url(format: :xml)
    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, essays(:published_new).slug
  end

  test "excludes drafts" do
    get sitemap_url(format: :xml)
    assert_not_includes response.body, essays(:draft).slug
  end
end
```

**Green:**
- `SitemapController#index` с `format: :xml`
- View: `sitemap/index.xml.builder`
- Кеширование 1 час через `fresh_when` или `expires_in`

---

## Этап 15: ERB partials + helpers

**Что делаем:** переиспользуемые партиалы и хелперы (`app/views/shared/`, `ApplicationHelper`).

**Red:**

```ruby
# test/helpers/application_helper_test.rb
class ApplicationHelperTest < ActionView::TestCase
  test "meta_tags renders og:title" do
    result = meta_tags(title: "My Essay", description: "About Rails")
    assert_match "og:title", result
  end

  test "meta_tags renders description" do
    result = meta_tags(title: "My Essay", description: "About Rails")
    assert_match "About Rails", result
  end

  test "meta_tags renders JSON-LD for article type" do
    result = meta_tags(title: "Essay", description: "Desc", type: :article, published_at: Time.current)
    assert_match '"@type":"Article"', result
  end

  test "picture_tag returns empty string when not attached" do
    attachment = essays(:draft).cover
    assert_equal "", picture_tag(attachment, alt: "test")
  end
end
```

**Green:**
- `app/helpers/application_helper.rb` — `meta_tags(title:, description:, image: nil, type: :website, published_at: nil)`, `picture_tag(attachment, alt:, sizes: nil)`
- `app/views/shared/_meta_tags.html.erb` — OG tags + canonical + JSON-LD
- `app/views/shared/_essay_card.html.erb`, `_build_card.html.erb`, `_book_row.html.erb`, `_field_card.html.erb`
- `app/views/shared/_flash.html.erb` — единый flash для обоих layouts
- Обновить public show-вьюхи: `content_for(:title)` + `content_for(:head) { meta_tags(...) }`
- Заменить inline карточки на index-страницах: `render "shared/essay_card", essay: essay`
- Обновить layouts: title с суффиксом, `yield :head`, `render "shared/flash"`

**Refactor:** после замены inline-разметки на партиалы — убедиться что system tests остаются зелёными.

---

## Этап 16: ~~System tests~~ — пропущен

Capybara + Selenium убраны из проекта. Контроллерные тесты (ActionDispatch::IntegrationTest) покрывают все критические flows: CRUD, авторизацию, коды ответов, редиректы. Для личного сайта без сложных JS-взаимодействий этого достаточно.

---

## Этап 17: Стили и Design Tokens

**Что делаем:** CSS-токены, типографика, layout, карточки.

**Red:**

```ruby
# test/system/design/responsive_layout_test.rb
class Design::ResponsiveLayoutTest < ApplicationSystemTestCase
  test "navigation is visible on desktop" do
    visit root_url
    assert_selector "nav"
    assert_link "Essays"
    assert_link "Builds"
    assert_link "Reading"
    assert_link "Field"
    assert_link "Now"
  end

  test "footer contains required links" do
    visit root_url
    within "footer" do
      assert_link "About"
      assert_link "Uses"
      assert_link "Contact"
      assert_link "RSS"
    end
  end
end
```

**Green:**
- `app/assets/stylesheets/tokens.css` — переменные: цвета, шрифты, отступы
- Шрифты Onest + JetBrains Mono в `app/assets/fonts/`
- Layout с nav и footer
- Карточки с hover-эффектом

---

## Этап 18: PWA + llms.txt + финальные штрихи

**Что делаем:** PWA-манифест, service worker, llms.txt, seeds.

**Red:**

```ruby
# test/controllers/pwa_test.rb
class PwaTest < ActionDispatch::IntegrationTest
  test "manifest returns valid JSON" do
    get "/manifest.json"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Fieldnotes", json["name"]
    assert json["icons"].any?
  end

  test "service worker returns JavaScript" do
    get "/service-worker.js"
    assert_response :success
    assert_match "application/javascript", response.media_type
  end
end
```

**Green:**
- Раскомментировать PWA routes
- Заполнить `manifest.json.erb` и `service-worker.js`
- Создать `public/llms.txt`
- Заполнить `db/seeds.rb` для создания admin-пользователя

---

## Сводная таблица

| Этап | Что | Тесты | Файлы |
|------|-----|-------|-------|
| 1 | Auth | model + controller | User, Session, Admin::Base |
| 2 | Essay | model | migration, model, concern |
| 3 | NowEntry | model | migration, model, paper_trail |
| 4 | Build | model | migration, model |
| 5 | Book | model | migration, model |
| 6 | Field* | model | 2 migrations, 2 models |
| 7 | Tag/Tagging | model | 2 migrations, concern |
| 8 | PageView | model + subscriber | migration, initializer |
| 9 | OpenLibrary | service | service class |
| 10 | ImageVariantJob | job | job class |
| 11 | ExportJob | job | job + model |
| 12 | Admin controllers | controller | 6 controllers + views |
| 13 | Public controllers | controller | 7 controllers + views |
| 14 | Sitemap + RSS | controller | controller + XML/RSS views |
| 15 | ERB partials + helpers | helper | meta_tags, cards, picture_tag |
| 16 | ~~System tests~~ | — | убраны, Capybara не используем |
| 17 | Design tokens | system | CSS + fonts + layout |
| 18 | PWA + finish | integration | PWA + seeds + llms.txt |

---

## Правило работы (напоминание)

При реализации каждого этапа:

1. **Red** — пишу тесты → запускаю → убеждаюсь что красные
2. **Green** — пишу минимальный код → тесты зелёные
3. **Refactor** — улучшаю → тесты остаются зелёными
4. Говорю **"Этап N готов, переходим к N+1"**
