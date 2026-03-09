# Миграция ERB → Phlex + Tailwind

План пошаговой миграции с сохранением всей функциональности.
Каждая фаза независима и деплоится отдельно — в любой момент проект работает.

---

## Почему Phlex + Tailwind

**Phlex:** компоненты — обычные Ruby-классы. AI знает Ruby превосходно.
Изолированные компоненты, явные зависимости через `initialize`, тестируются как Minitest-объекты.

**Tailwind:** классы видны прямо в компоненте — никаких глобальных CSS-каскадов.
`tailwindcss-rails` использует standalone binary — **Node.js не нужен**, деплой не меняется.

**Итог:** тот же Rails-монолит, тот же Turbo, тот же Stimulus. Только Views становятся чище.

---

## Что меняется, что остаётся

| Слой | До | После |
|---|---|---|
| Views | ERB partials | Phlex компоненты (Ruby) |
| CSS | Кастомные токены, 9 файлов | Tailwind utility classes |
| JS | Stimulus (без изменений) | Stimulus (без изменений) |
| Asset pipeline | Propshaft | Propshaft + tailwindcss-rails |
| Turbo | Без изменений | Без изменений |
| Lexxy | Без изменений | Без изменений |
| Ruby/Rails | Без изменений | Без изменений |
| База данных | Без изменений | Без изменений |
| Деплой | Без изменений | Без изменений |

---

## Фаза 0 — Настройка (1-2 часа)

### Gemfile

```ruby
# Добавить
gem "phlex-rails"
gem "tailwindcss-rails"

# Удалить после завершения миграции (пока оставить)
# ничего не удалять до Фазы 5
```

```bash
bundle install
bin/rails tailwindcss:install
bin/rails generate phlex:install
```

### Tailwind config — брендовые токены

Заменяет `tokens.css`. Все цвета в одном месте:

```js
// config/tailwind.config.js
const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./app/views/**/*.{rb,html,html.erb}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        bg:      "#0F0F0F",
        surface: "#1A1A1A",
        border:  "#2E2E2E",
        ink:     "#E8E3DC",   // основной текст
        muted:   "#888780",   // второстепенный
        accent:  "#E8722A",   // оранжевый
        "accent-hover": "#F08040",

        // Code
        "code-bg":   "#2A2A2A",
        "pre-bg":    "#1E1E1E",
        "code-text": "#E8C9A0",

        // Status
        "green-bg":   "#1A2E22",  "green-text":  "#6EE7A0",
        "blue-bg":    "#1A1F2E",  "blue-text":   "#93C5FD",
        "purple-bg":  "#1F1A2E",  "purple-text": "#C4B5FD",
        "amber-bg":   "#2A1E0A",  "amber-text":  "#FBB040",
        "red-bg":     "#2E1A1A",  "red-text":    "#F87171",
      },
      fontFamily: {
        sans: ["Onest", ...defaultTheme.fontFamily.sans],
        mono: ["JetBrains Mono", ...defaultTheme.fontFamily.mono],
      },
      maxWidth: {
        content: "70ch",
        wide:    "90rem",
      },
    },
  },
}
```

### Подключить Tailwind в layout (временно рядом со старым CSS)

```erb
<%# app/views/layouts/application.html.erb — добавить одну строку %>
<%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
<%# старые stylesheet_link_tag оставить до Фазы 5 %>
```

### Структура компонентов

```
app/views/
  components/
    application_component.rb    ← базовый класс
    layout/
      site_header.rb
      site_nav.rb
      site_footer.rb
    shared/
      flash_messages.rb
      badge.rb
      empty_state.rb
    essays/
      essay_card.rb
    builds/
      build_card.rb
      profile_hero.rb
    books/
      book_card.rb
      book_placeholder.rb
    field/
      field_card.rb
  public/
    essays/
      index_view.rb
      show_view.rb
    builds/
      index_view.rb
    books/
      index_view.rb
      show_view.rb
    field/
      index_view.rb
      show_view.rb
    now/
      show_view.rb
    feed/
      index_view.rb
    pages/
      about_view.rb
      contact_view.rb
      uses_view.rb
  admin/
    shared/
      form_field.rb
      page_header.rb
    essays/
      index_view.rb
      form_view.rb
    builds/
      index_view.rb
      form_view.rb
    books/
      index_view.rb
      form_view.rb
    field/
      index_view.rb
      show_view.rb
      form_view.rb
    nows/
      edit_view.rb
  layouts/
    application_layout.rb
    admin_layout.rb
    auth_layout.rb
```

### Базовый компонент

```ruby
# app/views/components/application_component.rb
class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag

  private

  # Утилита для склеивания классов (аналог clsx)
  def cx(*classes)
    classes.flatten.compact.join(" ")
  end
end
```

---

## Фаза 1 — Shared компоненты (2-3 часа)

Начинаем с листовых компонентов без зависимостей.

### Badge

```ruby
# app/views/components/shared/badge.rb
class Components::Shared::Badge < ApplicationComponent
  VARIANTS = {
    reading:   "bg-purple-bg text-purple-text",
    completed: "bg-green-bg text-green-text",
    abandoned: "bg-surface text-muted",
    active:    "bg-green-bg text-green-text",
    paused:    "bg-amber-bg text-amber-text",
    archived:  "bg-surface text-muted",
  }.freeze

  BASE = "inline-block px-2.5 py-0.5 rounded-full text-[0.6875rem] font-bold tracking-wider uppercase"

  def initialize(status)
    @status = status.to_sym
  end

  def view_template
    span(class: cx(BASE, VARIANTS.fetch(@status, "bg-surface text-muted"))) do
      @status.to_s.capitalize
    end
  end
end
```

### Flash

```ruby
# app/views/components/shared/flash_messages.rb
class Components::Shared::FlashMessages < ApplicationComponent
  def initialize(flash)
    @flash = flash
  end

  def view_template
    return if @flash.empty?

    div do
      @flash.each do |type, message|
        div(class: flash_classes(type)) { message }
      end
    end
  end

  private

  def flash_classes(type)
    base = "px-4 py-3 rounded-lg mb-4 text-[0.9375rem]"
    type == "notice" \
      ? "#{base} bg-green-bg text-green-text"
      : "#{base} bg-red-bg text-red-text"
  end
end
```

### Essay card

```ruby
# app/views/components/essays/essay_card.rb
class Components::Essays::EssayCard < ApplicationComponent
  CARD    = "bg-surface border border-border rounded-lg p-6 mb-6 shadow-sm " \
            "relative cursor-pointer transition hover:-translate-y-0.5 hover:shadow-md"
  TITLE   = "text-xl font-bold mb-2"
  LINK    = "text-ink hover:text-accent after:absolute after:inset-0 after:content-['']"
  EXCERPT = "text-muted mb-3"
  META    = "flex items-center gap-3 flex-wrap"

  def initialize(essay:)
    @essay = essay
  end

  def view_template
    article(class: CARD) do
      h2(class: TITLE) do
        link_to @essay.title, essay_path(@essay.slug), class: LINK
      end
      p(class: EXCERPT) { @essay.excerpt } if @essay.excerpt.present?
      div(class: META) do
        time(class: "text-muted text-sm") { @essay.published_at.strftime("%B %-d, %Y") }
        render Components::Shared::Badge.new(@essay.status) if @essay.status != "published"
      end
    end
  end
end
```

### Build card

```ruby
# app/views/components/builds/build_card.rb
class Components::Builds::BuildCard < ApplicationComponent
  CARD  = "bg-surface border border-border rounded-lg p-6 flex flex-col gap-3 " \
          "transition hover:border-accent hover:-translate-y-0.5"
  TITLE = "text-[1.0625rem] font-semibold mb-0"
  LINK  = "text-ink hover:text-accent"
  DESC  = "text-muted text-[0.9375rem] leading-relaxed m-0"

  def initialize(build:)
    @build = build
  end

  def view_template
    article(class: CARD) do
      div(class: "text-3xl leading-none") { @build.icon_emoji }
      div(class: "flex-1") do
        h3(class: TITLE) do
          link_to @build.title, @build.url, class: LINK, target: "_blank", rel: "noopener"
        end
        p(class: DESC) { @build.description }
      end
      render Components::Shared::Badge.new(@build.status)
    end
  end
end
```

### Book card

```ruby
# app/views/components/books/book_card.rb
class Components::Books::BookCard < ApplicationComponent
  def initialize(book:)
    @book = book
  end

  def view_template
    link_to book_path(@book), class: "flex flex-col gap-3 no-underline text-inherit group" do
      div(class: "w-full aspect-[2/3] rounded-lg overflow-hidden bg-surface shadow-sm " \
                  "transition group-hover:-translate-y-1 group-hover:shadow-md") do
        if @book.cover_url.present?
          img src: @book.cover_url, alt: @book.title,
              class: "w-full h-full object-cover block"
        else
          render Components::Books::BookPlaceholder.new(title: @book.title)
        end
      end
      div(class: "flex flex-col gap-0.5") do
        p(class: "text-[0.8125rem] font-semibold text-ink leading-snug") { @book.title }
        p(class: "text-xs text-muted") { @book.author }
        p(class: "text-[0.6875rem] text-accent tracking-widest") { "★" * @book.rating } if @book.rating
      end
    end
  end
end
```

```ruby
# app/views/components/books/book_placeholder.rb
class Components::Books::BookPlaceholder < ApplicationComponent
  def initialize(title:)
    @title = title
  end

  def view_template
    div(class: "w-full h-full flex flex-col items-center justify-center gap-2 p-4 text-center",
        style: "background: linear-gradient(160deg, #2A1A0F 0%, #1A0F08 100%); border: 1px solid #3D2010;") do
      span(class: "text-2xl leading-none") { "📖" }
      span(class: "text-muted text-xs font-medium leading-snug") { @title }
    end
  end
end
```

---

## Фаза 2 — Layouts (2-3 часа)

### Application layout

```ruby
# app/views/layouts/application_layout.rb
class Layouts::ApplicationLayout < ApplicationComponent
  include Phlex::Rails::Layout

  def view_template(&block)
    html do
      head do
        title { content_for(:title).present? ? "#{content_for(:title)} — Fieldnotes" : "Fieldnotes" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        csrf_meta_tags
        csp_meta_tag
        yield :head
        stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
        stylesheet_link_tag "lexxy-content", "lexxy-overrides", "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "bg-bg text-ink font-sans antialiased flex flex-col min-h-screen") do
        render Layouts::SiteHeader.new
        main(class: "flex-1 max-w-content mx-auto px-6 py-12 #{content_for(:main_class)}") do
          render Components::Shared::FlashMessages.new(flash)
          yield
        end
        render Layouts::SiteFooter.new
      end
    end
  end
end
```

```ruby
# app/views/layouts/site_header.rb
class Layouts::SiteHeader < ApplicationComponent
  NAV_LINK = "relative text-muted font-medium text-[0.9375rem] px-3 py-2 rounded-lg " \
             "transition hover:text-ink hover:bg-code-bg"
  ACTIVE   = "text-ink after:absolute after:bottom-[3px] after:left-3 after:right-3 " \
             "after:h-0.5 after:bg-accent after:rounded-sm after:content-['']"

  def view_template
    header(class: "border-b border-border bg-surface sticky top-0 z-10") do
      nav(class: "max-w-[90rem] mx-auto px-6 h-[3.25rem] flex items-center justify-between gap-6") do
        link_to "Fieldnotes", root_path, class: "font-bold text-base tracking-tight text-ink hover:text-accent flex-shrink-0"
        div(class: "flex items-center gap-1") do
          nav_link "Essays",  essays_path,      "essays"
          nav_link "Builds",  builds_path,      "builds"
          nav_link "Reading", books_path,        "books"
          nav_link "Field",   field_index_path, "field"
          nav_link "Now",     now_path,         "now"
        end
      end
    end
  end

  private

  def nav_link(label, path, controller_name)
    active = helpers.controller_path.end_with?(controller_name)
    link_to label, path, class: cx(NAV_LINK, active ? ACTIVE : nil),
            aria: { current: active ? "page" : nil }
  end
end
```

---

## Фаза 3 — Public views (3-4 часа)

Контроллеры остаются без изменений. Меняем только render.

### Подключение в контроллере

```ruby
# app/controllers/public/essays_controller.rb
def index
  @essays = Essay.published.order(published_at: :desc)
  render Public::Essays::IndexView.new(essays: @essays)
end

def show
  @essay = Essay.published.find_by!(slug: params[:slug])
  render Public::Essays::ShowView.new(essay: @essay)
end
```

### Essays index

```ruby
# app/views/public/essays/index_view.rb
class Public::Essays::IndexView < ApplicationComponent
  def initialize(essays:)
    @essays = essays
  end

  def view_template
    provide(:title, "Essays")

    h1(class: "text-3xl font-bold tracking-tight mb-8") { "Essays" }

    if @essays.empty?
      render Components::Shared::EmptyState.new("No essays yet.")
    else
      @essays.each { render Components::Essays::EssayCard.new(essay: it) }
    end
  end
end
```

### Books index

```ruby
# app/views/public/books/index_view.rb
class Public::Books::IndexView < ApplicationComponent
  def initialize(books:)
    @books = books
  end

  def view_template
    provide(:title, "Reading")
    provide(:main_class, "site-main--wide")   # пока используем старый класс

    h1(class: "text-3xl font-bold tracking-tight mb-8") { "Reading" }
    div(class: "grid grid-cols-5 gap-6 mt-8 " \
                "max-[900px]:grid-cols-4 max-[700px]:grid-cols-3 max-[480px]:grid-cols-2") do
      @books.each { render Components::Books::BookCard.new(book: it) }
    end
  end
end
```

---

## Фаза 4 — Admin views (4-5 часов)

Admin layout отдельный. Можно сделать после public views.

### Базовый admin form field

```ruby
# app/views/admin/shared/form_field.rb
class Admin::Shared::FormField < ApplicationComponent
  LABEL = "block text-sm font-medium text-muted mb-1"
  INPUT = "w-full bg-surface border border-border rounded-lg px-3 py-2 text-ink " \
          "focus:outline-none focus:border-accent transition"

  def initialize(form:, field:, label: nil, type: :text_field, **opts)
    @form  = form
    @field = field
    @label = label || field.to_s.humanize
    @type  = type
    @opts  = opts
  end

  def view_template
    div(class: "mb-4") do
      @form.label @field, @label, class: LABEL
      @form.public_send(@type, @field, class: INPUT, **@opts)
    end
  end
end
```

---

## Фаза 5 — Удаление старого CSS (1 час)

Только после того как ВСЕ ERB-шаблоны заменены.

```bash
# Удалить файлы
rm app/assets/stylesheets/tokens.css
rm app/assets/stylesheets/typography.css
rm app/assets/stylesheets/layout.css
rm app/assets/stylesheets/cards.css
rm app/assets/stylesheets/field.css
rm app/assets/stylesheets/essays.css
rm app/assets/stylesheets/admin.css
rm app/assets/stylesheets/app.css
# lexxy-overrides.css — оставить, он всё ещё нужен для Lexxy
```

```erb
<%# application_layout.rb — убрать старые теги %>
<%# Оставить только: tailwind, lexxy-content, lexxy-overrides %>
```

---

## Обработка нетипичных случаев

### Lexxy rich text

Lexxy рендерит HTML в `<div class="lexxy-content">`. Tailwind не стилизует произвольный HTML
по умолчанию — используй `@tailwindcss/typography` плагин или оставь `lexxy-overrides.css`.

```js
// tailwind.config.js
plugins: [require("@tailwindcss/typography")],
```

```ruby
# В компоненте для показа essay
div(class: "prose prose-invert max-w-none lexxy-content") do
  raw @essay.content.body.to_html
end
```

### `content_for` / `provide` в Phlex

```ruby
# В view-компоненте:
provide(:title, "Essays")
provide(:main_class, "some-class")

# В layout:
content_for(:title)   # читается как обычно
```

### Builders (RSS, XML, sitemap)

ERB-шаблоны для не-HTML форматов (`show.rss.builder`, `sitemap.xml.builder`, `show.md.erb`)
**оставить как есть** — Phlex не нужен там где нет UI.

### Маiler views

`app/views/passwords_mailer/` — оставить ERB. Phlex для email не нужен.

---

## Порядок миграции

```
Фаза 0 — Setup gems + Tailwind config          ← можно деплоить
Фаза 1 — Shared components (badge, flash, cards) ← можно деплоить
Фаза 2 — Layouts                               ← можно деплоить
Фаза 3 — Public views (по одной странице)      ← каждую отдельно
Фаза 4 — Admin views                           ← в конце
Фаза 5 — Удаление старых CSS-файлов            ← только после полной Фазы 4
```

Каждый шаг — отдельный коммит. Старые ERB файлы лежат рядом до момента удаления.

---

## Тестирование

### Unit тест компонента

```ruby
# test/views/components/essays/essay_card_test.rb
class EssayCardTest < Phlex::Testing::TestCase
  def test_renders_title
    essay = essays(:published)
    card  = Components::Essays::EssayCard.new(essay: essay)
    assert_includes render(card), essay.title
  end

  def test_renders_excerpt
    essay = essays(:published)
    assert_includes render(Components::Essays::EssayCard.new(essay: essay)), essay.excerpt
  end
end
```

### System test (Capybara — без изменений)

```ruby
# test/system/essays_test.rb — структура не меняется
test "visitor reads essay list" do
  visit essays_path
  assert_text "Essays"
  assert_selector "article", minimum: 1
end
```

---

## Инструменты

| Гем | Зачем |
|---|---|
| `phlex-rails` | Phlex интеграция с Rails rendering |
| `tailwindcss-rails` | Standalone Tailwind CLI, без Node.js |
| `@tailwindcss/typography` | npm plugin для стилизации rich text (prose) |

```ruby
# Gemfile
gem "phlex-rails"
gem "tailwindcss-rails"
```

```bash
bundle install
bin/rails tailwindcss:install   # создаёт config/tailwind.config.js + assets/stylesheets/application.tailwind.css
bin/rails generate phlex:install
```

После `tailwindcss:install` добавить в `Procfile.dev`:
```
css: bin/rails tailwindcss:watch
```
