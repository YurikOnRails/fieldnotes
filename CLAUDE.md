# Fieldnotes

A personal site & digital garden for developers, makers, and open source contributors.
Built on Rails 8.1 + Ruby 4 + SQLite (Solid Trifecta). Self-hosted, one VPS, one deploy command.
No Redis, no PaaS, no external services. MIT license.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, x86_64-linux, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Background jobs | Solid Queue |
| Cache | Solid Cache |
| WebSockets | Solid Cable |
| Asset pipeline | Propshaft |
| JavaScript | Importmaps + Stimulus |
| Views | ERB + ViewComponent |
| Rich text | Action Text + **Lexxy** (replaces Trix — new editor from 37signals, built on Meta's Lexical framework, beta) |
| File storage | Active Storage + libvips → WebP variants |
| Authentication | Rails built-in authentication generator |
| Deployment | Kamal 2 |
| Version management | mise (ruby@4.0.1 in .mise.toml) |

### Lexxy — Rich Text Editor

Lexxy is the next-generation rich text editor from 37signals that replaces Trix in the Rails ecosystem.
It is built on Meta's [Lexical framework](https://lexical.dev/docs/intro).

- **GitHub:** https://github.com/basecamp/lexxy
- **Lexical docs:** https://lexical.dev/docs/intro
- It integrates with Action Text — treat it as a drop-in Trix replacement
- Still in beta: check GitHub for the latest installation instructions before implementing
- Do NOT use Trix anywhere in this project

---

## UI Components

**Primary source:** [Preline UI](https://preline.co/docs/index.html) — use as the single source of truth for all UI components.

Rules:
- Find the closest existing Preline component before writing any UI from scratch
- Copy the HTML/CSS structure directly into ERB templates
- **Never include `preline.js`** — all interactive behavior is handled by Stimulus controllers
- Customize only colors and spacing to match the project design palette
- When a Preline component requires JS (dropdown, modal, tabs, accordion) — implement it as a Stimulus controller

### Preline → Stimulus mapping

| Preline component | Stimulus controller |
|---|---|
| Navbar collapse (mobile) | `mobile_menu_controller.js` |
| Dropdown menu | `dropdown_controller.js` |
| Modal / overlay | `modal_controller.js` |
| Tabs | `tabs_controller.js` |
| Accordion | `accordion_controller.js` |
| Toast / alert dismiss | `alert_controller.js` |
| YouTube embed | `youtube_controller.js` (facade pattern — see below) |
| Photo gallery / lightbox | `gallery_controller.js` |
| Autosave form | `autosave_controller.js` |
| Clipboard copy | `clipboard_controller.js` |

---

## Data Models

```ruby
essays:       id, title, slug, excerpt, status(draft/published), published_at
              has_rich_text :content   # rendered by Lexxy
              has_one_attached :cover

projects:     id, title, slug, description,
              status(active/paused/completed/abandoned),
              url, stack_tags, started_on, finished_on
              has_one_attached :cover

books:        id, title, author, cover_url, year_read, rating(1-5),
              key_idea(text), status(reading/completed/abandoned)

craft_series: id, title, slug, description,
              kind(photo/video/mixed), location, taken_on

craft_items:  id, craft_series_id, kind(photo/video), caption,
              position, youtube_url
              has_one_attached :photo

now_entries:  id, body(rich text), published_at
              has_paper_trail

tags:         id, name, slug

taggings:     id, tag_id, taggable_id, taggable_type  # polymorphic
```

---

## Application Structure

```
app/
├── controllers/
│   ├── public/        # essays, projects, books, craft, now, feed
│   └── admin/         # base + all sections; custom admin, no ActiveAdmin
├── models/
├── views/
│   ├── components/    # ViewComponent: essay_card, book_card, project_card,
│   │                  #   craft_series_card, photo_gallery, youtube_embed
│   ├── layouts/       # application.html.erb, admin.html.erb
│   ├── public/
│   └── admin/
├── jobs/
│   ├── image_variant_job.rb   # warm WebP variants after upload
│   └── export_job.rb          # full data export to ZIP
├── services/
│   └── open_library_service.rb  # ISBN → book metadata + cover URL
└── javascript/controllers/
    ├── gallery_controller.js
    ├── youtube_controller.js   # facade pattern — lazy load
    ├── autosave_controller.js
    ├── mobile_menu_controller.js
    ├── dropdown_controller.js
    └── clipboard_controller.js
```

---

## Routes

```ruby
root "public/feed#index"

scope module: :public do
  resources :essays,   only: [:index, :show], param: :slug
  resources :projects, only: [:index, :show], param: :slug
  resources :books,    only: [:index]
  resources :craft,    only: [:index, :show], param: :slug
  get "/now", to: "now#show"
end

namespace :admin do
  root "essays#index"
  resources :essays, :projects, :books
  resources :craft do
    resources :craft_items, only: [:create, :destroy, :update]
  end
  resource :now, only: [:edit, :update]
end
```

---

## Navigation (Hick's Law — max 5 items)

```
Essays | Projects | Reading | Craft | Now
```

Footer only (not in nav): /about · /uses · /contact · GitHub · RSS

---

## Coding Conventions

- **Ruby 4.0 features are welcome:** PRISM parser, `it` block parameter
- **Prefer ViewComponent over partials** for any reusable UI element
- **Prefer Stimulus** for JS behavior; never add preline.js or any third-party JS UI library
- **Slugs are human-readable:** `/essays/rails-sqlite-production-2026`
- `paper_trail` on `NowEntry` for public revision history
- Image variants warmed via `ImageVariantJob` after upload (never inline)
- No videos stored locally — YouTube embed via facade pattern (lazy load, youtube-nocookie.com)
- YJIT enabled in production via `config/environments/production.rb`
- No ActiveAdmin — custom admin controllers under `Admin::BaseController`

---

## Rails 8 / 8.1 Features — Use These

This project is a showcase of modern Rails. Always prefer built-in Rails 8/8.1 solutions over gems or custom code.

### Active Job Continuations (Rails 8.1) → ExportJob

Use `ActiveJob::Continuable` for `ExportJob`. If Kamal restarts the container mid-export, the job resumes from the last completed step — not from scratch.

```ruby
class ExportJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(user_id)
    step :export_data  { export_json_files }
    step :export_files { |step| copy_attachments(step) }
    step :build_zip    { build_archive }
    step :notify       { notify_user(user_id) }
  end
end
```

### Local CI DSL (Rails 8.1) → config/ci.rb

Define CI steps in `config/ci.rb`, run with `bin/ci`. No external CI service needed for contributors.

```ruby
CI.run do
  step "Setup",    "bin/setup --skip-server"
  step "Rubocop",  "bin/rubocop"
  step "Brakeman", "bin/brakeman --quiet"
  step "Tests",    "bin/rails test"
  step "System",   "bin/rails test:system"
end
```

### Markdown Rendering (Rails 8.1) → Essays

Essays expose a `.md` format endpoint — useful for RSS readers, CLI tools, and AI agents.

```ruby
# public/essays_controller.rb
respond_to do |format|
  format.html
  format.md { render plain: @essay.content.to_markdown }
end
```

Route: `GET /essays/:slug.md`

### Structured Event Reporting (Rails 8.1) → Self-hosted analytics

Use `Rails.event.notify` to track page views into SQLite. Zero external services, zero JS trackers.

```ruby
# Track essay views
Rails.event.notify("essay.viewed", essay_id: @essay.id, slug: @essay.slug)

# Subscriber writes to SQLite via a simple PageView model
```

Add a `page_views` table: `id, event, payload(json), created_at`. Subscribe in an initializer.

### Rate Limiting (Rails 8.0) → RSS + public endpoints

Built-in, no Rack::Attack needed.

```ruby
# application_controller.rb
rate_limit to: 60, within: 1.minute, only: :index
```

Apply to: RSS feed, `/essays.md`, `/essays` index.

### YJIT (Ruby 4 / Rails production)

```ruby
# config/environments/production.rb
config.yjit = true  # ~15-20% performance boost, zero config
```

---

## Design Principles

- Background: warm cream `#FAF9F7`, not pure white
- Fonts: Cabinet Grotesk (display), system-ui (body), JetBrains Mono (code)
- Body text: 18–21px, 60–75 chars per line
- Mobile-first; F-pattern — important content in first words of headings
- Personal voice throughout — not corporate language
- Reference aesthetic: Basecamp.com philosophy + warmth
- **No dark mode in v1**

---

## Intentionally NOT in v1

Do not implement or suggest these features:

- Comments
- Search
- Dark theme
- Analytics (no GA; SQLite counter or self-hosted Plausible later)
- Email newsletter
- Multi-user support
- GitHub API integration (project stats not displayed)
- preline.js or any JS UI framework
- `/pulse` page — planned for v2 (see below)
- `/map` page — planned for v3, coordinate fields added to models now

---

## Planned: /pulse — "The World Right Now" (v2)

A real-time dashboard showing live data from public APIs. Updates via Action Cable + Solid Cable — already in the stack, no new dependencies.

**Route:** `GET /pulse` — added to public navigation in v2

### Data sources — all free, no API key required

| Metric | Source | Update frequency |
|---|---|---|
| CO₂ in atmosphere (ppm) | NOAA API | Daily |
| Bitcoin price | CoinGecko API — `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd` | Every 30s |
| People in space | Open Notify — `http://api.open-notify.org/astros.json` | On change |
| ISS position | Open Notify — `http://api.open-notify.org/iss-now.json` | Every 30s |
| Earthquakes today | USGS — `https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson` | Every 5min |
| US national debt | US Treasury Fiscal Data API | Daily |

### Architecture

```
Reader browser ←── Turbo Streams over Action Cable ──── Solid Cable (SQLite)
                                        ↑
                                  PulseJob (every 30s)
                                  fetches external APIs
                                  caches in Solid Cache
                                  broadcasts HTML fragments via Turbo::StreamsChannel
```

One line in the view subscribes to the channel — no JS boilerplate:

```erb
<%# app/views/public/pulse/index.html.erb %>
<%= turbo_stream_from "pulse" %>

<div id="co2_ppm">  <%= render "co2_ppm",  ppm:   @co2_ppm %>   </div>
<div id="btc_price"><%= render "btc_price", price: @btc_price %> </div>
<div id="iss">      <%= render "iss",       data:  @iss %>        </div>
<div id="quakes">   <%= render "quakes",    list:  @quakes %>     </div>
```

### PulseJob — broadcasts Turbo Stream HTML fragments

```ruby
class PulseJob < ApplicationJob
  def perform
    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "btc_price",
      partial: "public/pulse/btc_price",
      locals: { price: CoinGeckoService.bitcoin_price }

    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "iss",
      partial: "public/pulse/iss",
      locals: { data: OpenNotifyService.iss_position }

    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "quakes",
      partial: "public/pulse/quakes",
      locals: { list: UsgsService.today_list }

    PulseJob.set(wait: 30.seconds).perform_later
  end
end
```

Server controls the HTML — no JSON parsing in JS, no manual DOM updates. Standard Rails partials.

### Solid Cache TTL per source

| Source | TTL | Fallback if unavailable |
|---|---|---|
| NOAA CO₂ | 24 hours | Last cached value |
| CoinGecko | 30 seconds | Last cached value |
| Open Notify | 30 seconds | Last cached value |
| USGS | 5 minutes | Last cached value |

Always show last cached value if external API is unavailable — never show an error or blank to the reader.

### Stimulus — only for client-side counters

`pulse_controller.js` handles **only** animated counters that tick locally in the browser (e.g. world population incrementing every 100ms). Server data updates are handled entirely by Turbo Streams — no Action Cable subscription needed in JS.

```javascript
// Only for smooth local counters — not for server data
startCounter(baseValue, ratePerSecond) {
  setInterval(() => {
    baseValue += ratePerSecond / 10
    this.element.textContent = Math.floor(baseValue).toLocaleString()
  }, 100)
}
```

**Rule:** if data comes from the server → Turbo Streams partial. If it animates locally in browser → Stimulus counter.

### Services

```
app/services/
  noaa_service.rb          # CO₂ ppm
  coin_gecko_service.rb    # Bitcoin price
  open_notify_service.rb   # ISS + astronauts
  usgs_service.rb          # Earthquakes
```

Each service: single `.fetch` class method, wraps in `Rails.cache.fetch` with appropriate TTL, returns last cached value on network error.

### Rules

- Never call external APIs inline in a controller — always through a service + Solid Cache
- `PulseJob` self-reschedules — if it fails, it does not restart automatically. Add monitoring via Solid Queue dashboard
- Page is fully readable without WebSocket — initial render shows cached values, WS enriches progressively
- Rate limit `/pulse` to 30 req/min — bots should not trigger API polling

---

## Planned: /map — Travel Map (v3)

Coordinate fields added to models now so data accumulates from day one. Map UI built in v3 when 20+ locations exist.

```ruby
# Already in schema from v1 migrations:
# essays:       latitude, longitude, location_name
# craft_series: latitude, longitude  (location string already exists)
```

Map renders from a GeoJSON endpoint. Tech: Mapbox GL JS (free tier, 50k loads/month) or MapLibre GL (fully open source). Single `map_controller.js` Stimulus controller.

---

## Testing (TDD)

This project follows TDD. Write tests before implementation.

- **Framework:** Minitest (Rails default) + Capybara for system tests
- **Always write tests first** — no pull request or feature without corresponding tests
- Test files mirror app structure: `test/models/`, `test/controllers/`, `test/system/`
- Use `fixtures` for test data, not FactoryBot
- Run tests with `bin/rails test` and `bin/rails test:system`
- Use `bin/ci` for full CI run — defined in `config/ci.rb` (Rails 8.1 built-in, no external CI needed)

### Test coverage expectations

| Layer | Tool | What to test |
|---|---|---|
| Models | Minitest | validations, scopes, methods |
| Controllers | ActionDispatch | response codes, redirects, auth |
| System | Capybara + Selenium | critical user flows end-to-end |
| Jobs | Minitest | ExportJob, ImageVariantJob |

---

## Data Export

Admin panel includes a **full data export** button. Generates a ZIP archive via `ExportJob` (Solid Queue + `ActiveJob::Continuable`), delivered via Turbo Stream notification with a download link.

### ZIP structure

```
fieldnotes-export-YYYY-MM-DD/
├── data/
│   ├── essays.json
│   ├── projects.json
│   ├── books.json
│   ├── craft_series.json
│   ├── craft_items.json
│   ├── now_entries.json
│   └── tags.json
├── files/
│   ├── essays/covers/
│   ├── craft/photos/
│   └── projects/covers/
└── README.md
```

### Rules

- `README.md` inside the archive documents the JSON format for third-party importers
- All models exported — this is a full ownership export, not selective
- JSON fields match database column names exactly (no camelCase transformation)
- Files exported as originals from Active Storage (not WebP variants)
- Archive attached to Active Storage, link expires after 24 hours
- One export at a time — enqueue only if no pending `ExportJob` exists

---

## External Services

### Open Library API — Books metadata

Fetches book cover and metadata by ISBN. Free, no API key required.

- **Docs:** https://openlibrary.org/developers/api
- **Cover URL pattern:** `https://covers.openlibrary.org/b/isbn/{ISBN}-L.jpg`
- **Metadata endpoint:** `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`
- Implemented in `app/services/open_library_service.rb`
- Cache results in Solid Cache for **7 days** — metadata rarely changes
- Store `cover_url` as a plain string on the `books` table (no Active Storage for book covers)
- Graceful fallback: if API unavailable, show a placeholder cover, never raise

```ruby
# Usage in admin books controller
book_data = OpenLibraryService.fetch(isbn: "9780316769174")
# => { title:, author:, cover_url:, year: }
```

Do NOT use GitHub API. Project stats (stars, last commit) are not displayed in Fieldnotes.

---

## Performance

Always apply these patterns. No exceptions.

### HTTP caching on all public actions

```ruby
# Every public#show action
def show
  @essay = Essay.published.find_by!(slug: params[:slug])
  fresh_when @essay  # sets ETag + Last-Modified, returns 304 if unchanged
end

# Every public#index action
def index
  @essays = Essay.published.order(published_at: :desc)
  fresh_when @essays
end
```

### Solid Cache TTL rules

| Data | TTL | Reason |
|---|---|---|
| Open Library book metadata | 7 days | Rarely changes |
| Essay rendered HTML fragment | 1 hour | Content changes infrequently |
| Now page | 10 minutes | Updated often |
| Feed (RSS) | 30 minutes | Balance freshness vs load |

### N+1 prevention

- Always use `includes` when rendering collections
- Install `bullet` gem in development — it raises on N+1 queries
- Never add `.each` in views without checking the query in logs first

```ruby
# Always — never load associations lazily in collections
@essays = Essay.published.includes(:tags, :cover_attachment).order(published_at: :desc)
```

### Never inline image variants

Always warm variants via `ImageVariantJob` after upload. Never call `.variant()` inline in a view.

---

## Web Push Notifications

Readers can subscribe to browser push notifications. When a new essay is published, a push is sent via `NotifySubscribersJob`.

- **Gem:** `web-push` — no Firebase, no external service, no email required
- Subscriptions stored in SQLite (`push_subscriptions` table)
- Permission prompt shown once via Stimulus controller
- Triggered by `after_commit` on `Essay` when status changes to `published`

### Data model

```ruby
push_subscriptions: id, endpoint, p256dh_key, auth_key, created_at
```

### Flow

```ruby
# Essay model
after_commit :notify_subscribers, on: :update

def notify_subscribers
  return unless saved_change_to_status?(from: "draft", to: "published")
  NotifySubscribersJob.perform_later(id)
end
```

```ruby
# NotifySubscribersJob — uses ActiveJob::Continuable for large subscriber lists
class NotifySubscribersJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(essay_id)
    essay = Essay.find(essay_id)
    step :push do |step|
      PushSubscription.find_each(start: step.cursor) do |sub|
        WebPush.payload_send(
          endpoint: sub.endpoint,
          message: JSON.dump(title: essay.title, url: essay_url(essay)),
          p256dh: sub.p256dh_key,
          auth: sub.auth_key,
          vapid: { subject: Rails.application.credentials.vapid_subject,
                   public_key: Rails.application.credentials.vapid_public_key,
                   private_key: Rails.application.credentials.vapid_private_key }
        )
        step.advance! from: sub.id
      end
    end
  end
end
```

### Stimulus controller

`push_controller.js` — requests permission and POSTs subscription to `/push_subscriptions`.

### Routes

```ruby
resources :push_subscriptions, only: [:create, :destroy]
```

### Rules

- VAPID keys stored in Rails credentials (`rails credentials:edit`), never in ENV
- Gracefully handle expired/invalid subscriptions — delete on `WebPush::ExpiredSubscription` error
- No third-party push service — everything self-hosted via VAPID protocol
- ServiceWorker file lives at `public/service_worker.js` (served at root scope)

---

## PWA — Progressive Web App

Rails 8 generates PWA files automatically. Fieldnotes is installable as a standalone app on desktop and mobile — no App Store needed.

Generated files (already in Rails 8 scaffold):
```
app/views/pwa/manifest.json.erb   # app metadata
app/views/pwa/service_worker.js   # shares file with Web Push
public/icons/icon-192.png         # required
public/icons/icon-512.png         # required
```

### manifest.json.erb

```json
{
  "name": "Fieldnotes",
  "short_name": "Fieldnotes",
  "description": "A personal site & digital garden",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FAF9F7",
  "theme_color": "#FAF9F7",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

### service_worker.js — shared with Web Push

One file handles both PWA offline caching and Web Push notifications.

```javascript
const CACHE = "fieldnotes-v1"
const OFFLINE_URLS = ["/", "/essays", "/offline"]

// Cache core pages on install
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(OFFLINE_URLS))
  )
})

// Serve from cache, fall back to network, fall back to /offline
self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
      .catch(() => caches.match("/offline"))
  )
})

// Web Push handler lives here too (see Web Push section)
```

### Offline page

Add a `/offline` route and `public/offline.html` — shown when reader has no internet and the page isn't cached. Keep it minimal: logo, message, list of cached essays.

### Rules

- Icons generated from a single SVG source — use `vips` (already installed for Active Storage) to produce 192px and 512px PNG variants
- Increment `CACHE` version string when deploying breaking changes to force cache refresh
- Do NOT cache admin routes — offline mode is for public readers only
- PWA and Web Push share a single `service_worker.js` — never split into two files
- Test installability with Chrome DevTools → Application → Manifest

---

## Image Optimization

All photos go through a three-layer optimization pipeline. Never serve raw uploads to readers.

### Format priority: AVIF → WebP → JPEG

```ruby
# app/models/craft_item.rb
VARIANTS = {
  thumb:  { resize_to_fill:  [400, 300],   format: :avif, saver: { quality: 75 } },
  medium: { resize_to_limit: [800, 600],   format: :avif, saver: { quality: 80 } },
  full:   { resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 85 } },
  hero:   { resize_to_fill:  [1600, 900],  format: :avif, saver: { quality: 85 } }
}
```

Same variant set applies to `essay` covers and `project` covers.

### picture tag — responsive images in PhotoGalleryComponent

Always use `<picture>` with three sources. Never plain `image_tag` for photos.

```erb
<picture>
  <source
    srcset="<%= url_for(photo.variant(format: :avif, resize_to_limit: [400, 300])) %> 400w,
            <%= url_for(photo.variant(format: :avif, resize_to_limit: [800, 600])) %> 800w,
            <%= url_for(photo.variant(format: :avif, resize_to_limit: [1600, 1200])) %> 1600w"
    type="image/avif">

  <source
    srcset="<%= url_for(photo.variant(format: :webp, resize_to_limit: [400, 300])) %> 400w,
            <%= url_for(photo.variant(format: :webp, resize_to_limit: [800, 600])) %> 800w,
            <%= url_for(photo.variant(format: :webp, resize_to_limit: [1600, 1200])) %> 1600w"
    type="image/webp">

  <%= image_tag photo.variant(resize_to_limit: [800, 600]),
      loading: "lazy",
      sizes: "(max-width: 768px) 100vw, 50vw",
      alt: item.caption %>
</picture>
```

### Blur-up loading effect — blur_up_controller.js

Show a tiny 20×20px placeholder instantly, swap to full image after load.

```javascript
// app/javascript/controllers/blur_up_controller.js
export default class extends Controller {
  static targets = ["thumb", "full"]

  connect() {
    const img = new Image()
    img.src = this.fullTarget.dataset.src
    img.onload = () => {
      this.fullTarget.src = img.src
      this.thumbTarget.classList.add("opacity-0", "transition-opacity")
    }
  }
}
```

### Rules

- **AVIF first** — best compression (~55% smaller than JPEG at same quality)
- **WebP fallback** — for browsers without AVIF support (~7% of users)
- **JPEG last resort** — only as final fallback inside `<picture>`
- `loading="lazy"` on all photos **except** the first visible image in viewport — use `loading="eager"` on hero
- All variants warmed by `ImageVariantJob` after upload — never generate variants inline in views
- libvips handles all conversion — already installed for Active Storage, no extra dependencies
- Store originals in Active Storage untouched — variants are generated on demand then cached

### Watermark

Craft photos (travel) get a subtle watermark before variants are generated. Originals are always stored clean.

**Pipeline order:**
```
Original (stored clean in Active Storage)
    ↓
Watermarked copy (in-memory, never persisted)
    ↓
AVIF / WebP variants generated from watermarked copy
```

**Implementation inside `ImageVariantJob`:**

```ruby
def apply_watermark(image)
  watermark = Vips::Image.new_from_file(
    Rails.root.join("app/assets/images/watermark.png").to_s
  )

  # Scale watermark to 12% of photo width — works for any resolution
  scale     = (image.width * 0.12) / watermark.width
  watermark = watermark.resize(scale)

  # Bottom-right corner, 24px padding
  left = image.width  - watermark.width  - 24
  top  = image.height - watermark.height - 24

  image.composite(watermark, :over, x: left, y: top)
end
```

**watermark.png** — PNG with transparent background, ~200×40px at 1920px reference size. Contains: `© fieldnotes.dev` or author name. Stored at `app/assets/images/watermark.png`.

**Where to apply:**

| Attachment | Watermark |
|---|---|
| `craft_items` photos | ✅ yes — public travel content |
| `essays` covers | ⚠️ optional — author's choice |
| `books` covers | ❌ no — third-party content |
| Admin previews | ❌ no — not public |

**Rules:**
- Original blob is never modified — watermark applied to in-memory copy only
- Watermark opacity: 40% (`composite :over` with pre-multiplied alpha in PNG)
- Watermark scales proportionally — 12% of image width at all resolutions
- If watermark file missing — skip silently, log warning, continue variant generation

### Expected file sizes after optimization

| Original | AVIF 1920px | WebP 1920px | Savings |
|---|---|---|---|
| JPEG 4MB | ~180KB | ~280KB | 95% / 93% |
| Page with 12 photos | ~2MB total | — | vs 48MB raw |

---

## Turbo Conventions

### Decision table

| Situation | Use |
|---|---|
| Admin form save (create/update) | `redirect_to` — simple, cacheable |
| Admin form validation error | `render :new/edit, status: :unprocessable_entity` |
| Delete a record from list | Turbo Stream → remove the card from DOM |
| Autosave draft | Stimulus `autosave_controller` → PATCH → 204 No Content |
| Export job progress | Turbo Stream broadcast from `ExportJob` |
| Flash messages after redirect | Turbo Stream appended to `#flash` target |
| Lazy-load content on scroll | Turbo Frame with `src` attribute |
| Mobile menu, dropdown, modal | Stimulus controller — no Turbo needed |

### Rules

- Prefer `redirect_to` over Turbo Streams for standard CRUD — simpler and more predictable
- Use Turbo Streams only when a partial DOM update genuinely improves UX (delete row, append notification)
- Turbo Frames for lazy-loading sections that are slow or optional (e.g., book cover loaded after page)
- Never broadcast Turbo Streams to unauthenticated users
- All Turbo Stream templates live in `views/[resource]/[action].turbo_stream.erb`

---

## Deployment

```yaml
# config/deploy.yml (Kamal 2)
volumes:
  - fieldnotes_storage:/rails/storage   # Active Storage files
  - fieldnotes_db:/rails/db             # SQLite databases
```

---

## GitHub

- **Repo:** fieldnotes
- **Description:** "A personal site & digital garden for developers, makers, and open source contributors. Rails 8.1 · Ruby 4 · SQLite · Solid Queue/Cache/Cable · Kamal 2. Self-hosted. No Redis, no PaaS."
- **Topics:** ruby-on-rails, personal-site, digital-garden, blog, sqlite, kamal, self-hosted, solid-queue, open-source, rails-8
- **License:** MIT
