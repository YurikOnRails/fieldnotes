<div align="center">
  <h1>Fieldnotes</h1>
  <p>
    A personal site that's actually yours.<br>
    Essays, builds, reading log, field expeditions, and a /now page.<br>
    One server. One database file. Zero trackers.
  </p>
  <p>
    <a href="https://www.ruby-lang.org"><img src="https://img.shields.io/badge/Ruby-4.0.1-CC342D?style=flat-square&logo=ruby" alt="Ruby 4.0.1"></a>
    <a href="https://rubyonrails.org"><img src="https://img.shields.io/badge/Rails-8.1.2-D30001?style=flat-square&logo=rubyonrails" alt="Rails 8.1.2"></a>
    <a href="https://www.sqlite.org"><img src="https://img.shields.io/badge/SQLite-production-003B57?style=flat-square&logo=sqlite" alt="SQLite"></a>
    <a href="https://kamal-deploy.org"><img src="https://img.shields.io/badge/Kamal_2-deploy-4A154B?style=flat-square" alt="Kamal 2"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License"></a>
  </p>
</div>

<!-- TODO: Replace with actual screenshot
<p align="center">
  <img src="docs/screenshot.png" alt="Fieldnotes screenshot" width="720">
</p>
-->

---

I built this because I wanted a personal site that doesn't spy on my readers, doesn't need 15 services to run, and actually belongs to me. Not to a SaaS company. Not to a cloud platform. To me.

Fieldnotes is a full Rails app — admin panel, rich text editor, image pipeline, background jobs — running on a **$4/mo server** with a **single SQLite file**. Fork it, make it yours, deploy in 30 minutes.

---

## Quick start

```bash
git clone https://github.com/YurikOnRails/fieldnotes.git
cd fieldnotes
mise install      # Ruby 4.0.1
bin/setup         # gems + database
bin/dev           # http://localhost:3000
```

That's it. No Redis. No PostgreSQL. No Node.js. No Yarn.

[Detailed setup guide](docs/getting-started.md) · [Deploy to production](docs/deployment.md)

---

## Who is this for?

Developers who write. Makers who share their work. People who want a home on the internet that's actually theirs.

## Who is this NOT for?

If you need multi-author publishing, e-commerce, 50 plugins, or a visual drag-and-drop builder — use WordPress. Fieldnotes is a one-person site for people who value simplicity and ownership.

---

## What's inside

### Core (always included)

> **Essays** — long-form writing with Lexxy editor, cover images, human-readable URLs (`/essays/rails-sqlite-production`), Markdown export, full-text RSS
>
> **Now** — what you're doing right now ([nownownow.com](https://nownownow.com) tradition), with built-in version history

### Optional (enable what you need, remove what you don't)

> **Builds** — a visual grid of everything you've created: businesses, open source projects, media channels, communities, key links. Your personal catalog — like a Linktree, but built into your site and fully yours
>
> **Reading** — public reading log. One field matters: `key_idea` — what did you take away? Book covers auto-fetched from Open Library
>
> **Field** — photo and video expedition series. Document your travels, explorations, and fieldwork. AVIF/WebP pipeline, watermarks, privacy-respecting YouTube embeds

No hidden dependencies between modules. Don't do expeditions? Remove Field — everything else works.

---

## Why not...

| | ❌ The problem | ✅ Fieldnotes |
|---|---|---|
| **Hugo / Jekyll** | No admin panel. Edit files in git. No images, no jobs, no real-time. | Full app — write in a real editor, manage from the browser |
| **WordPress** | PHP + MySQL + plugins that phone home. Security patches forever. | Ruby + SQLite. Minimal surface area. Zero third-party requests |
| **Ghost** | SaaS at $9+/mo or complex self-hosting. Proprietary editor. | $4/mo VPS, `kamal deploy`, done. Open source editor |
| **Astro / Next.js** | Node + npm + dozens of dependencies. Build your own admin. | No Node.js at all. Admin panel included. 5 commands to deploy |

---

## Privacy-first

Fieldnotes makes **zero third-party requests**. None.

Your readers get a fast, clean experience — no consent popups, no surveillance.

| | |
|---|---|
| **Fonts** | Self-hosted Onest + JetBrains Mono (`.woff2` in the repo). No Google Fonts. |
| **Analytics** | Server-side page views via `Rails.event.notify`. Stored in your SQLite. No JS trackers. |
| **Assets** | All icons, fonts, and styles served from your server. No CDN calls. |
| **Cookies** | None. No tracking cookies = no cookie banner needed. |
| **Data export** | Full ZIP from admin panel — JSON data + original files. Your data, always. |

---

## Tech stack

Built on the latest Ruby and Rails. Minimal dependencies. No external services.

| | |
|---|---|
| **Ruby 4.0.1** | PRISM parser + YJIT (~15-20% faster in production) |
| **Rails 8.1** | Solid Queue + Solid Cache + Solid Cable — jobs, cache, WebSockets without Redis |
| **SQLite** | Production database. One file. WAL mode. Backup = copy. |
| **Lexxy** | Rich text editor from 37signals, built on Meta's Lexical |
| **Kamal 2** | Zero-downtime deploys. SSL via Let's Encrypt. Any VPS. |
| **Propshaft + Importmaps** | No Webpack. No Vite. No npm. |
| **Active Storage + libvips** | AVIF/WebP variants. Background processing. No cloud services. |

---

## Rails 8 showcase

This project exists partly to show what Rails 8 does out of the box — no gems for things the framework already handles:

| Feature | Replaces |
|---|---|
| Solid Queue | Redis + Sidekiq |
| Solid Cache | Redis / Memcached |
| Solid Cable | Redis / AnyCable |
| ActiveJob::Continuable | Custom retry logic |
| Built-in auth | Devise |
| `rate_limit` | Rack::Attack |
| `fresh_when` | Manual cache headers |
| `format.md` | Custom API endpoints |
| `bin/ci` | GitHub Actions (for local CI) |
| YJIT | Nothing — free 15-20% performance |

---

## Deploy

```bash
kamal setup    # first time — installs Docker, builds, deploys, SSL
kamal deploy   # every time after — zero downtime
```

**Hetzner CX22** — $4.51/mo, 2 vCPU, 4GB RAM, 40GB disk.
Enough for years of content and ~10,000 photos.

[Step-by-step deployment guide](docs/deployment.md) — from "I have nothing" to a live site.

---

## Docs

| Doc | Description |
|---|---|
| [Getting Started](docs/getting-started.md) | Setup, prerequisites, admin account |
| [Deployment](docs/deployment.md) | VPS, Kamal, SSL, backups |
| [Design System](docs/design.md) | Tokens, typography, layout |
| [SEO](docs/seo.md) | JSON-LD, Open Graph, RSS, analytics |
| [Images](docs/images.md) | AVIF/WebP pipeline, watermarks |
| [Rails 8 Features](docs/rails8-features.md) | Code examples |
| [Data Export](docs/export.md) | ZIP archive format |
| [PWA](docs/pwa.md) | Offline support |

---

## Contributing

Fieldnotes is built in the open. Contributions welcome — especially from people running it for their own sites.

- Check out issues tagged [`good first issue`](../../labels/good%20first%20issue)
- We write tests first — no PR is merged without tests
- Lexxy compatibility fixes are especially valuable

---

## Roadmap

- [x] Essays, Builds, Books, Field, Now
- [x] Admin panel with Lexxy editor
- [x] AVIF/WebP image pipeline
- [x] Self-hosted analytics (zero JS)
- [x] Full data export (ZIP)
- [x] PWA support
- [ ] `/pulse` — real-time dashboard with public API data
- [ ] `/map` — travel map from essay and photo coordinates
- [ ] Dark mode

See [open issues](../../issues) for what's being worked on.

---

## Philosophy

**Own your platform.** One SQLite file, one server, full control. Not renting from a SaaS that might raise prices, shut down, or sell your data.

**Respect your readers.** Zero third-party requests. No Google Fonts. No tracking scripts. No cookie banners. Your visitors deserve a clean experience.

**Keep it simple.** You don't need a JS framework, a headless CMS, a managed database, and five microservices for a personal site. You need Rails, SQLite, and a $4 server.

**Build in the open.** MIT license. Fork it, learn from it, make it yours. That's the point.

---

<p align="center">
  <b>If Fieldnotes is useful to you, consider giving it a star.</b><br>
  It helps others find the project and motivates development.<br><br>
  <a href="../../stargazers">Star this repo</a> · <a href="../../fork">Fork it</a> · <a href="../../issues">Report a bug</a>
</p>

---

<p align="center">
  MIT License · Built with Rails 8.1, Ruby 4, and stubbornness.
</p>
