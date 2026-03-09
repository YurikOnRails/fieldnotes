# Fieldnotes — LLM Context

Instructions for AI assistants working on this codebase.
For project overview, see `README.md`. For detailed guides, see `docs/`.

---

## Philosophy

This is a **Majestic Monolith**. One app. One database. One server. One deploy. No microservices, no queues in the cloud, no managed databases, no Kubernetes. You don't need any of that. You need to ship something beautiful and own it completely.

We write Ruby on Rails the **omakase** way — the chef has chosen the ingredients, don't swap them out. When Rails gives you something, use it. When a gem offers what Rails already does, delete the gem. When a framework offers what vanilla HTML+CSS does, delete the framework.

This app runs on **SQLite**. Not because we couldn't afford Postgres. Because SQLite is the right tool for a personal site. It's faster for reads, simpler to operate, and trivially backed up with `cp`. Anyone who says you can't run SQLite in production hasn't tried Litestack.

The web is **HTML over the wire**. Turbo makes pages feel instant. Stimulus adds just enough JS where behavior is needed. The browser is not a runtime for a JavaScript application — it's a document viewer that happens to support interactivity. Respect that.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ruby | 4.0.1 (PRISM parser, YJIT in production) |
| Rails | 8.1.2 |
| Database | SQLite via Litestack |
| Jobs / Cache / WS | Solid Queue · Solid Cache · Solid Cable |
| Assets | Propshaft · Importmaps · Stimulus |
| Views | ERB partials + helpers |
| Rich text | Action Text + **Lexxy** (beta — do NOT use Trix) |
| Images | Active Storage + libvips → AVIF/WebP |
| Auth | Rails built-in authentication generator |
| Deploy | Kamal 2 |

**Lexxy:** 37signals editor on Meta's Lexical. GitHub: https://github.com/basecamp/lexxy
Current pinned version: `0.8.0.beta`. Replaces Trix completely — `form.rich_text_area` renders Lexxy automatically.
Before upgrading — check GitHub for breaking changes first.
If Lexxy breaks after update — pin the last working version in Gemfile, open an issue upstream, fix and PR.
Rendered content requires `.lexxy-content` wrapper (see `app/views/layouts/action_text/contents/_content.html.erb`).
Admin layout should load full `lexxy.css`; public layout only `lexxy-content.css` (split when admin layout is created at stage 12).

**CSS:** Custom CSS + design tokens (`app/assets/stylesheets/tokens.css`).
No Tailwind. No Preline. No Pico. No utility classes. CSS is a language — write it.
All interactivity via Stimulus. No Alpine, no HTMX, no React, no Vue. Not because they're bad — because we don't need them.

---

## Content Modules

Essays and /now are the soul of this app. Everything else is optional.
Disable optional modules by removing routes, nav links, and admin controllers. Don't leave dead code.

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

**The Rails Way is not a limitation. It's a gift.**

- **Ruby 4.0 features welcome:** `it` block parameter, PRISM parser. Write modern Ruby.
- **ERB only — no ViewComponent.** ViewComponent adds abstraction where Rails already has partials. Shared markup → `app/views/shared/_partial.html.erb`. Tag-generating logic → helper in `ApplicationHelper`. Don't build a component framework inside a framework.
- **Stimulus for JS** — one controller per behavior, data attributes for config. If you're writing more than 50 lines in a Stimulus controller, reconsider the design.
- **Slugs are for humans:** `/essays/rails-sqlite-production-2026` — not `/essays/1234`
- **Never inline image variants** — warm via `ImageVariantJob` after upload. The web is visual; broken images are broken trust.
- No videos stored locally — YouTube facade (`youtube-nocookie.com`). Storage is expensive, YouTube's CDN is not.
- No ActiveAdmin — custom controllers under `Admin::BaseController`. ActiveAdmin trades control for speed. We don't make that trade.
- No GitHub API — project stats not displayed. Real work doesn't need a commit counter.
- **Prefer Rails 8 built-ins over gems** (see `docs/rails8-features.md`). Every gem is a dependency. Every dependency is a liability.
- **Less software.** The best code is code you didn't write. Before adding a feature, ask whether removing something achieves the same goal.
- **Beautiful code matters.** Not clever code. Not terse code. Code that reads like prose and does exactly what it says.

---

## Testing

**Test behavior, not implementation.** Coverage percentages are a vanity metric. A test suite that gives you confidence to deploy is the only metric that matters.

- Minitest + fixtures (no FactoryBot — factories are complexity that compounds)
- Capybara for system tests against a real browser
- `bin/ci` runs full suite via `config/ci.rb`
- Models: test validations, scopes, business methods
- Controllers: response codes, redirects, auth boundaries
- System: the critical paths a user actually walks

No mocks for the database. Use real fixtures, real queries, real results. If your test doesn't touch the database, ask why you're testing it at all.

---

## What We're NOT Building (and why)

Every "no" here is deliberate. Features have carrying costs. Complexity compounds. A personal site that tries to do everything ends up doing nothing well.

- **No comments** — the internet doesn't need another comment section
- **No search** — good navigation and RSS make search unnecessary at this scale
- **No dark mode** — design with intention, not infinite toggle switches
- **No payments** — not yet; keep the money stuff out of v1
- **No `/pulse` dashboard** — vanity metrics in real-time (v2, see `docs/pulse.md`)
- **No `/map`** — coordinate fields are being collected now; the map comes later (v3)
- **No Web Push** — nobody needs another notification
- **No multi-user** — this is a personal site, not a platform
- **No newsletter/email subscriptions** — RSS is the original subscribe
- **No bidirectional links / graph view** — reconsider at 200+ essays; until then it's premature
- **No AI-generated content** — this app exists to publish a human voice, not simulate one
- **No Webmentions, WebSub** — IndieWeb complexity that serves nobody reading this site
- **No JS UI libraries** — not Preline, not Alpine, not anything. Stimulus is the ceiling.

---

## On Dependencies

When you're tempted to add a gem, ask:

1. Does Rails already do this?
2. Can I write this in under 30 lines?
3. Is this gem actively maintained and trusted?

If Rails does it, use Rails. If you can write it, write it. Only reach for a gem when the answer to both is no and the alternative is genuinely worse.

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
