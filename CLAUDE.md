# Fieldnotes

**The Rails 8 reference app for personal sites.**

Fork it, deploy to a $4/mo VPS in 15 minutes, make it yours.
Digital garden: essays, projects, books, photography, /now page.

Built on Rails 8.1 + Ruby 4 + SQLite. No Redis, no PaaS, no JS frameworks.
One server, one deploy command, full ownership of your data. MIT license.

**Why not Jekyll/Hugo/Next.js?** Full Rails app — admin panel, rich text editor,
image pipeline, background jobs, real-time updates, self-hosted analytics.
All the things static generators can't do, without the complexity of a JS stack.

**Mission:** Demonstrate Rails 8 superiority for indie developers. Build personal brand.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Jobs / Cache / WS | Solid Queue · Solid Cache · Solid Cable |
| Assets | Propshaft · Importmaps · Stimulus |
| Views | ERB + ViewComponent |
| Rich text | Action Text + **Lexxy** (beta — do NOT use Trix) |
| Images | Active Storage + libvips → AVIF/WebP |
| Auth | Rails built-in authentication generator |
| Deploy | Kamal 2 |

**Lexxy:** 37signals editor on Meta's Lexical. GitHub: https://github.com/basecamp/lexxy
Check GitHub for current install instructions before implementing.

**CSS:** Custom CSS + design tokens (`app/assets/stylesheets/tokens.css`).
No Tailwind, no Preline, no Pico. All interactivity via Stimulus.

---

## Data Models

```ruby
essays:       title, slug, excerpt, status(draft/published), published_at,
              latitude, longitude, location_name
              has_rich_text :content   # Lexxy
              has_one_attached :cover

projects:     title, slug, description, status(active/paused/completed/abandoned),
              url, repo_url, stack_tags, started_on, finished_on
              has_one_attached :cover

books:        title, author, cover_url, year_read, rating(1-5),
              key_idea(text), status(reading/completed/abandoned)

craft_series: title, slug, description, kind(photo/video/mixed),
              location, taken_on, latitude, longitude

craft_items:  craft_series_id, kind(photo/video), caption, position, youtube_url
              has_one_attached :photo

now_entries:  body(rich text), published_at — has_paper_trail

tags/taggings: polymorphic (tag_id, taggable_id, taggable_type)
page_views:    event(string), payload(json), created_at
```

---

## Routes

```ruby
root "public/feed#index"

scope module: :public do
  resources :essays,   only: [:index, :show], param: :slug  # .rss + .md on show
  resources :projects, only: [:index, :show], param: :slug  # .rss on index
  resources :books,    only: [:index]
  resources :craft,    only: [:index, :show], param: :slug
  get "/now",     to: "now#show"
  get "/feed",    to: "feed#index"    # .rss — unified feed
  get "/contact", to: "pages#contact"
  get "/about",   to: "pages#about"
  get "/uses",    to: "pages#uses"
end

get "/sitemap.xml", to: "sitemap#index", defaults: { format: :xml }

namespace :admin do
  root "essays#index"
  resources :essays, :projects, :books
  resources :craft do
    resources :craft_items, only: [:create, :destroy, :update]
  end
  resource :now, only: [:edit, :update]
end
```

Nav: `Essays | Projects | Reading | Craft | Now`
Footer: /about · /uses · /contact · GitHub · RSS (`/feed.rss`)

---

## Coding Conventions

- **Ruby 4.0 features welcome:** `it` block parameter, PRISM parser
- **ViewComponent over partials** for reusable UI
- **Stimulus for JS** — never add preline.js or any JS UI framework
- **Slugs human-readable:** `/essays/rails-sqlite-production-2026`
- `paper_trail` on `NowEntry` for public revision history
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

---

## GitHub

- **Description:** "The Rails 8 reference app for personal sites. Digital garden with essays, projects, books, photography & /now page. Ruby 4 · SQLite · Kamal 2. Fork, deploy to a $4/mo VPS, make it yours."
- **Topics:** ruby-on-rails, personal-site, digital-garden, sqlite, kamal, self-hosted, rails-8, open-source, reference-app
- **License:** MIT
