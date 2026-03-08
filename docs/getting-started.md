# Getting Started

Fork → clone → run locally in 5 minutes.

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Ruby | 4.0.1 | `mise install ruby@4.0.1` (see `.mise.toml`) |
| mise | latest | https://mise.jdx.dev |
| libvips | 8.15+ | `apt install libvips-dev` / `brew install vips` |
| SQLite | 3.45+ | Usually pre-installed on macOS/Linux |

No Redis, no PostgreSQL, no Node.js, no Yarn.

---

## Setup

```bash
# 1. Clone
git clone https://github.com/YOUR_USER/fieldnotes.git
cd fieldnotes

# 2. Install Ruby (if not already)
mise install

# 3. Install dependencies + create database
bin/setup

# 4. Start the development server
bin/dev
```

Open http://localhost:3000 — you should see the homepage.

---

## Create your admin user

```bash
bin/rails console
```

```ruby
User.create!(
  email_address: "you@example.com",
  password: "your_secure_password"
)
```

Admin panel: http://localhost:3000/admin

---

## Environment variables

Development works with zero configuration. For production, set these in `.env` or Kamal secrets:

| Variable | Required | Description |
|---|---|---|
| `SECRET_KEY_BASE` | yes | `bin/rails secret` to generate |
| `RAILS_MASTER_KEY` | yes | Already in `config/master.key` (don't commit) |
| `KAMAL_REGISTRY_PASSWORD` | deploy only | Docker registry token |

No API keys needed — Open Library and all v1 integrations are free and keyless.

---

## Key commands

```bash
bin/dev          # Start dev server (Rails + Solid Queue)
bin/ci           # Run full test suite (rubocop, brakeman, tests)
bin/rails test   # Run unit + controller tests
bin/rails test:system  # Run Capybara system tests
```

---

## Making it yours

1. **Content:** Replace essays, projects, books via admin panel
2. **Hero:** Replace the hero photo in Active Storage via admin
3. **Branding:** Edit design tokens in `app/assets/stylesheets/tokens.css`
4. **Fonts:** Swap `.woff2` files in `app/assets/fonts/` and update `@font-face` in stylesheets
5. **Watermark:** Replace `app/assets/images/watermark.png` with your own
6. **PWA icons:** Replace `public/icons/icon-192.png` and `icon-512.png`
7. **Analytics:** Events auto-track via `Rails.event.notify` — no configuration needed

---

## Project structure

See `CLAUDE.md` for the full architecture overview, data models, routes, and coding conventions.
See `docs/` for detailed guides on images, deployment, data export, and Rails 8 features.
