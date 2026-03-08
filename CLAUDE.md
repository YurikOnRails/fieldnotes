# Fieldnotes

**The Rails 8 reference app for personal sites.**

A production-ready digital garden and personal site — essays, projects, books, photography, and a /now page.
Fork it, deploy to a $4/mo VPS in 15 minutes, make it yours.

Built on Rails 8.1 + Ruby 4 + SQLite. No Redis, no PaaS, no external JS frameworks.
One server, one deploy command, full ownership of your data. MIT license.

**Why not Jekyll/Hugo/Next.js?** This is a full Rails app — admin panel, rich text editor,
image pipeline, background jobs, real-time updates, self-hosted analytics. All the things
static generators can't do, without the complexity of a JS stack.

**Mission:** Demonstrate that Rails 8 is the best full-stack framework for indie developers.
Promote ideas publicly, attract talented people, build personal brand.
**Future:** `/contact` → sponsorship + collaboration ("Support / Collaborate" button in v2+).

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Background jobs | Solid Queue |
| Cache | Solid Cache |
| WebSockets | Solid Cable |
| Asset pipeline | Propshaft |
| JavaScript | Importmaps + Stimulus |
| Views | ERB + ViewComponent |
| Rich text | Action Text + **Lexxy** (beta, replaces Trix — do NOT use Trix) |
| File storage | Active Storage + libvips → AVIF/WebP variants |
| Authentication | Rails built-in authentication generator |
| Deployment | Kamal 2 |
| Version management | mise (ruby@4.0.1 in .mise.toml) |

**Lexxy:** Next-gen editor from 37signals built on Meta's Lexical. GitHub: https://github.com/basecamp/lexxy.
Still beta — check GitHub for current installation instructions before implementing.

**CSS:** No framework. Custom CSS with design tokens (`app/assets/stylesheets/tokens.css`).
No Preline, no Tailwind, no Pico — the visual identity is hand-crafted and intentional.
All interactivity via Stimulus controllers.

---

## Homepage Layout

```
┌─────────────────────────────────────────────┐
│  HERO: wide portrait photo + name + tagline  │
│  (who I am, 2-3 sentences, personal voice)  │
├─────────────────────────────────────────────┤
│  Big tiles grid: Essays · Projects ·        │
│  Reading · Craft · Now                      │
├─────────────────────────────────────────────┤
│  Recent: latest essay + latest project      │
└─────────────────────────────────────────────┘
```

Animations — subtle, CSS-first:
- Fade-in on scroll via `IntersectionObserver` in Stimulus (`reveal_controller.js`)
- Hover on tiles: `scale(1.02)` + shadow — pure CSS, no JS
- Typewriter effect in hero tagline — one line, `typewriter_controller.js`
- No parallax, no animation libraries (GSAP etc.), no spinning elements

---

## Data Models

```ruby
essays:       id, title, slug, excerpt, status(draft/published), published_at,
              latitude, longitude, location_name
              has_rich_text :content   # Lexxy
              has_one_attached :cover

projects:     id, title, slug, description,
              status(active/paused/completed/abandoned),
              url, repo_url, stack_tags, started_on, finished_on
              has_one_attached :cover

books:        id, title, author, cover_url, year_read, rating(1-5),
              key_idea(text), status(reading/completed/abandoned)

craft_series: id, title, slug, description,
              kind(photo/video/mixed), location, taken_on,
              latitude, longitude

craft_items:  id, craft_series_id, kind(photo/video), caption,
              position, youtube_url
              has_one_attached :photo

now_entries:  id, body(rich text), published_at
              has_paper_trail

tags:         id, name, slug
taggings:     id, tag_id, taggable_id, taggable_type  # polymorphic

page_views:   id, event, payload(json), created_at    # analytics
```

---

## Application Structure

```
app/
├── controllers/
│   ├── public/        # essays, projects, books, craft, now, feed
│   └── admin/         # custom admin — no ActiveAdmin
├── models/
├── views/
│   ├── components/    # ViewComponent: essay_card, book_card, project_card,
│   │                  #   craft_series_card, photo_gallery, youtube_embed
│   ├── layouts/       # application.html.erb, admin.html.erb
│   ├── public/
│   └── admin/
├── jobs/
│   ├── image_variant_job.rb   # warm AVIF/WebP variants after upload
│   └── export_job.rb          # full data export to ZIP (ActiveJob::Continuable)
├── services/
│   └── open_library_service.rb  # ISBN → book metadata + cover URL
└── javascript/controllers/
    ├── reveal_controller.js       # fade-in on scroll
    ├── typewriter_controller.js   # hero tagline animation
    ├── gallery_controller.js
    ├── youtube_controller.js      # facade pattern — lazy load, youtube-nocookie.com
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
  get "/now",     to: "now#show"
  get "/contact", to: "pages#contact"
  get "/about",   to: "pages#about"
  get "/uses",    to: "pages#uses"
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

## Navigation

```
Essays | Projects | Reading | Craft | Now
```

Footer only: /about · /uses · /contact · GitHub · RSS

---

## Coding Conventions

- **Ruby 4.0 features welcome:** `it` block parameter, PRISM parser
- **ViewComponent over partials** for any reusable UI element
- **Stimulus for JS** — never add preline.js or any JS UI framework
- **Slugs human-readable:** `/essays/rails-sqlite-production-2026`
- `paper_trail` on `NowEntry` for public revision history
- **Never inline image variants** — always warm via `ImageVariantJob` after upload
- No videos stored locally — YouTube facade pattern (`youtube-nocookie.com`)
- YJIT: `config.yjit = true` in `production.rb`
- No ActiveAdmin — custom controllers under `Admin::BaseController`
- No GitHub API — project stats not displayed

---

## Rails 8 / 8.1 — Use Built-in Features First

Always prefer Rails 8/8.1 built-ins over gems. See [`docs/rails8-features.md`](docs/rails8-features.md) for code examples.

| Feature | Use case |
|---|---|
| `ActiveJob::Continuable` | `ExportJob` — resume on container restart |
| `config/ci.rb` + `bin/ci` | Local CI, no external service needed |
| `format.md` response | Essays expose `/essays/:slug.md` for RSS readers / AI agents |
| `Rails.event.notify` | Self-hosted analytics → `page_views` table, zero JS trackers |
| `rate_limit` | RSS feed, `/essays` index, `/essays.md` — 60 req/min |
| `config.yjit = true` | Production performance, ~15-20% boost |
| `fresh_when` | HTTP caching on every public action (ETag + Last-Modified) |

---

## Analytics (Rails.event.notify — in v1)

```ruby
# In every public controller action:
Rails.event.notify("essay.viewed", essay_id: @essay.id, slug: @essay.slug)

# Subscriber in config/initializers/analytics.rb writes to page_views table
```

Zero external services. Zero JS. Pure Rails 8.1 + SQLite.

---

## Performance Rules

- `fresh_when @record` on every public `show` and `index` action
- `includes` always when rendering collections — never lazy-load associations in views
- `bullet` gem in development — raises on N+1
- Solid Cache TTL: book metadata 7d · essay fragment 1h · now page 10min · RSS 30min
- AVIF → WebP → JPEG pipeline via `<picture>` tag. See [`docs/images.md`](docs/images.md)
- Open Library API results cached 7 days. See [`docs/open-library.md`](docs/open-library.md)

---

## Turbo Conventions

| Situation | Use |
|---|---|
| Admin form save | `redirect_to` |
| Validation error | `render :new/edit, status: :unprocessable_entity` |
| Delete from list | Turbo Stream → remove card |
| Autosave draft | Stimulus `autosave_controller` → PATCH → 204 |
| Export progress | Turbo Stream broadcast from `ExportJob` |
| Flash after redirect | Turbo Stream → `#flash` target |
| Lazy-load section | Turbo Frame with `src` |
| Menu / modal / dropdown | Stimulus only — no Turbo |

Never broadcast Turbo Streams to unauthenticated users.

---

## Design Principles

Reference aesthetic: Basecamp — warm, human, content-first. Not corporate, not a template.

### Typography — self-hosted, no Google Fonts (privacy)

Fonts live in `app/assets/fonts/`. No CDN requests, no third-party tracking.

| Role | Font | Weights |
|---|---|---|
| Body + UI | **Onest** (supports Cyrillic + Latin) | 400, 500, 600, 700 |
| Code blocks | **JetBrains Mono** | 400, 500 |

`font-display: swap` on all `@font-face` declarations. Only `.woff2` — no other formats needed.

### Design Tokens (`app/assets/stylesheets/tokens.css`)

```css
:root {
  --color-bg:           #FAF9F7;
  --color-surface:      #FFFFFF;
  --color-border:       #E8E3DC;
  --color-text:         #1C1917;
  --color-muted:        #78716C;
  --color-accent:       #2D6A4F;
  --color-accent-hover: #235A42;

  --font-sans:   'Onest', system-ui, sans-serif;
  --font-mono:   'JetBrains Mono', monospace;
  --text-base:   1.125rem;
  --leading:     1.7;

  --radius-card: 14px;
  --radius-btn:  999px;
  --shadow-card: 0 1px 3px rgba(0,0,0,0.07), 0 4px 12px rgba(0,0,0,0.04);
  --shadow-hover: 0 4px 8px rgba(0,0,0,0.10), 0 12px 24px rgba(0,0,0,0.07);
}
```

### Rules

- Background `#FAF9F7`, cards `#FFFFFF` — warm contrast, not harsh white-on-white
- Navigation: emoji + text label (`✍️ Essays`) — human, zero icon dependencies
- Card hover: `translateY(-2px)` + `--shadow-hover` — pure CSS, no JS
- Body text: 18–21px, 60–75 chars/line, mobile-first
- Buttons: pill shape (`border-radius: 999px`), accent fill for CTA
- Icons: Unicode emoji for nav · [Phosphor Icons](https://phosphoricons.com/) SVG sprite for UI chrome (MIT, multi-weight: use `light` for decorative, `bold` for functional). Self-hosted, no CDN.
- Personal voice in every line — not corporate language
- F-pattern: key words first in every heading
- No dark mode in v1

---

## Testing (TDD)

Write tests before implementation. No PR without tests.

- Minitest + fixtures (no FactoryBot) + Capybara for system tests
- `bin/ci` runs full suite via `config/ci.rb`
- Models: validations, scopes, methods
- Controllers: response codes, redirects, auth
- System: critical user flows (Capybara + Selenium)

---

## NOT in v1

- Comments
- Search
- Dark mode
- Sponsorship / payment integration (v2+)
- Live activity sidebar on homepage (v2, when content accumulates)
- `/pulse` real-time dashboard (v2) — see [`docs/pulse.md`](docs/pulse.md)
- `/map` travel map (v3) — coordinate fields added to models now for data accumulation
- Web Push notifications (removed — too early without subscribers)
- Multi-user support
- preline.js or any JS UI library

---

## Deployment

```yaml
# config/deploy.yml (Kamal 2)
volumes:
  - fieldnotes_storage:/rails/storage   # Active Storage
  - fieldnotes_db:/rails/db             # SQLite
```

Hetzner CX22 ($4/mo, 40GB). Storage: ~10,000 photos at 535KB/photo.

---

## GitHub

- **Description:** "The Rails 8 reference app for personal sites. Digital garden with essays, projects, books, photography & /now page. Ruby 4 · SQLite · Kamal 2. Fork, deploy to a $4/mo VPS, make it yours."
- **Topics:** ruby-on-rails, personal-site, digital-garden, sqlite, kamal, self-hosted, rails-8, open-source, reference-app
- **License:** MIT
