# Fieldnotes — LLM Context

Instructions for AI assistants working on this codebase.
For project overview, see `README.md`. For detailed guides, see `docs/`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Jobs / Cache / WS | Solid Queue · Solid Cache · Solid Cable |
| Assets | Propshaft · Importmaps · Stimulus |
| Views | ERB partials + ViewComponent (see rule below) |
| Rich text | Action Text + **Lexxy** (beta — do NOT use Trix) |
| Images | Active Storage + libvips → AVIF/WebP |
| Auth | Rails built-in authentication generator |
| Deploy | Kamal 2 |

**Lexxy:** 37signals editor on Meta's Lexical. GitHub: https://github.com/basecamp/lexxy
Check GitHub for current install instructions before implementing.
We actively test and contribute fixes to Lexxy. If Lexxy breaks after update —
pin the last working version in Gemfile, open an issue upstream, fix and PR.

**CSS:** Custom CSS + design tokens (`app/assets/stylesheets/tokens.css`).
No Tailwind, no Preline, no Pico. All interactivity via Stimulus.

---

## Content Modules

Essays and /now are core. Everything else is optional —
disable by removing routes, nav link, and admin controllers.

| Module | Core? |
|---|---|
| Essays | yes |
| Now | yes |
| Builds | optional — card grid catalog: businesses, OSS projects, channels, key links |
| Books | optional — `key_idea` field is the point, not a Goodreads clone |
| Field | optional — photo/video expedition series with AVIF pipeline and watermarks |

---

## Data Models

```ruby
# CORE
essays:       title, slug, excerpt, status(draft/published), published_at,
              latitude, longitude, location_name
              has_rich_text :content   # Lexxy
              has_one_attached :cover

now_entries:  body(rich text), published_at
              # multiple records = natural history; show latest + archive of previous

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

- **Ruby 4.0 features welcome:** `it` block parameter, PRISM parser
- **ViewComponent** when used in 2+ places OR has render logic (cards, `<picture>`, meta tags, flash). **ERB partial** for one-off templates (admin forms, layouts, static pages, show views)
- **Stimulus for JS** — never add preline.js or any JS UI framework
- **Slugs human-readable:** `/essays/rails-sqlite-production-2026`
- **Never inline image variants** — warm via `ImageVariantJob` after upload
- No videos stored locally — YouTube facade (`youtube-nocookie.com`)
- No ActiveAdmin — custom controllers under `Admin::BaseController`
- No GitHub API — project stats not displayed
- Prefer Rails 8 built-ins over gems (see `docs/rails8-features.md`)

---

## Testing

Write tests before implementation. No PR without tests.

- Minitest + fixtures (no FactoryBot) + Capybara for system tests
- `bin/ci` runs full suite via `config/ci.rb`
- Models: validations, scopes, methods
- Controllers: response codes, redirects, auth
- System: critical user flows (Capybara + Selenium)

---

## NOT in v1

- Comments, search, dark mode
- Sponsorship / payments (v2+)
- `/pulse` real-time dashboard (v2) — see `docs/pulse.md`
- `/map` travel map (v3) — coordinate fields added now for data accumulation
- Web Push, multi-user, newsletter/email subscriptions
- Bidirectional links / graph view (reconsider at 200+ essays)
- AI-generated summaries / chatbot (contradicts personal voice)
- Webmentions, WebSub — not worth the complexity
- preline.js or any JS UI library

---

## Detailed docs (read when working on specific areas)

| Topic | File |
|---|---|
| Local setup, first user, env vars | [`docs/getting-started.md`](docs/getting-started.md) |
| Kamal, VPS, SSL, backups | [`docs/deployment.md`](docs/deployment.md) |
| Design tokens, typography, layout, homepage | [`docs/design.md`](docs/design.md) |
| SEO, JSON-LD, OG tags, RSS, analytics, Turbo, performance | [`docs/seo.md`](docs/seo.md) |
| Image pipeline, variants, watermark, picture tag | [`docs/images.md`](docs/images.md) |
| Rails 8 feature code examples | [`docs/rails8-features.md`](docs/rails8-features.md) |
| Data export (ZIP) | [`docs/export.md`](docs/export.md) |
| Open Library API | [`docs/open-library.md`](docs/open-library.md) |
| PWA manifest + service worker | [`docs/pwa.md`](docs/pwa.md) |
| /pulse real-time dashboard (v2) | [`docs/pulse.md`](docs/pulse.md) |
