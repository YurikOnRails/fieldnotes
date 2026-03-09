# Fieldnotes — LLM Context

Instructions for AI assistants working on this codebase.
For architecture decisions and philosophy, see `docs/architecture.md`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Jobs / Cache / WS | Solid Queue · Solid Cache · Solid Cable |
| Assets | Propshaft · Importmaps · Stimulus |
| Views | **Phlex** components (`app/views/components/`) |
| Styling | **Tailwind CSS v4** (via `tailwindcss-rails`) |
| Rich text | Action Text + **Lexxy** `0.8.0.beta` — do NOT use Trix |
| Images | Active Storage + libvips → AVIF/WebP |
| Auth | Rails built-in authentication generator |
| Deploy | Kamal 2 |

**Hard rules:** No ERB partials for UI components — use Phlex. No ViewComponent. No Alpine/HTMX/React/Vue. No ActiveAdmin.
Use Tailwind utility classes — no custom CSS except for things Tailwind cannot express. Dark theme, orange accent (`orange-500`).
Lexxy replaces Trix — `form.rich_text_area` renders Lexxy automatically. See `docs/design.md`.

---

## Phlex Conventions

- All UI components live in `app/views/components/` and inherit from `ApplicationComponent < Phlex::HTML`.
- Page views live in `app/views/pages/` (e.g. `Essays::IndexView`), inheriting from `ApplicationView`.
- Layouts are Phlex components in `app/views/layouts/`.
- Controllers render Phlex views: `render EssaysIndexView.new(essays: @essays)`.
- Shared markup → a Phlex component, not a partial. Logic → the component itself or a helper module.
- Keep `#view_template` focused; extract sub-components when a component exceeds ~80 lines.
- Use `@slots` / `renders_one` / `renders_many` for composable components.

---

## Data Models

```ruby
# CORE
essays:       title, slug, excerpt, status(draft/published), published_at,
              latitude, longitude, location_name
              has_rich_text :content   # Lexxy
              has_one_attached :cover

now_entries:  body(rich text), published_at

# OPTIONAL
builds:       title, slug, description, url, icon_emoji,
              status(active/paused/completed/archived), kind(business/oss/media/community/other),
              position, started_on, finished_on
              has_one_attached :cover

books:        title, author, cover_url, year_read, rating(1-5),
              key_idea(text), status(reading/completed/abandoned)

field_series: title, slug, description, kind(photo/video/mixed),
              location, taken_on, latitude, longitude

field_items:  field_series_id, kind(photo/video), caption, position, youtube_url
              has_one_attached :photo

# SYSTEM
tags/taggings: polymorphic (tag_id, taggable_id, taggable_type)
page_views:    event(string), payload(json), created_at
```

---

## Routes

```ruby
root "public/feed#index"

scope module: :public do
  resources :essays,   only: [:index, :show], param: :slug  # .rss + .md on show
  resources :builds,   only: [:index]
  resources :books,    only: [:index]
  resources :field,    only: [:index, :show], param: :slug
  get "/now",     to: "now#show"
  get "/feed",    to: "feed#index"    # .rss — unified feed
  get "/contact", to: "pages#contact"
  get "/about",   to: "pages#about"
  get "/uses",    to: "pages#uses"
end

get "/sitemap.xml", to: "sitemap#index", defaults: { format: :xml }

namespace :admin do
  root "essays#index"
  resources :essays, :builds, :books
  resources :field do
    resources :field_items, only: [:create, :destroy, :update]
  end
  resource :now, only: [:edit, :update]
end
```

Nav: `Essays | Builds | Reading | Field | Now`
Footer: /about · /uses · /contact · GitHub · RSS (`/feed.rss`)

---

## Coding Conventions

- **Ruby 4.0:** use `it` block parameter, PRISM parser. Write modern Ruby.
- **Phlex for all views** — no ERB for UI. Use Tailwind utility classes for styling.
- **Stimulus for JS** — one controller per behavior. >50 lines → reconsider the design.
- **Slugs are human-readable:** `/essays/rails-sqlite-production-2026` not `/essays/1234`
- **Never inline image variants** — warm via `ImageVariantJob` after upload.
- **Videos:** YouTube facade only (`youtube-nocookie.com`) — no local storage.
- **Prefer Rails 8 built-ins over gems.** See `docs/rails8-features.md`.

---

## Testing

- Minitest + fixtures — no FactoryBot
- Capybara for system tests
- `bin/ci` runs the full suite
- No DB mocks — real fixtures, real queries

---

## Docs

| Topic | File |
|---|---|
| Architecture & philosophy | [`docs/architecture.md`](docs/architecture.md) |
| Local setup, first user, env vars | [`docs/getting-started.md`](docs/getting-started.md) |
| Kamal, VPS, SSL, backups | [`docs/deployment.md`](docs/deployment.md) |
| Design tokens, typography, layout | [`docs/design.md`](docs/design.md) |
| SEO, JSON-LD, OG tags, RSS, performance | [`docs/seo.md`](docs/seo.md) |
| Image pipeline, variants, watermark | [`docs/images.md`](docs/images.md) |
| Rails 8 feature code examples | [`docs/rails8-features.md`](docs/rails8-features.md) |
| Data export (ZIP) | [`docs/export.md`](docs/export.md) |
| Open Library API | [`docs/open-library.md`](docs/open-library.md) |
| PWA manifest + service worker | [`docs/pwa.md`](docs/pwa.md) |
| /pulse real-time dashboard (v2) | [`docs/pulse.md`](docs/pulse.md) |
