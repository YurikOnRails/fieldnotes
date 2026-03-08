# Fieldnotes

**The Rails 8 reference app for personal sites.**

A digital garden for developers, makers, and independent thinkers. Essays, projects, reading log, photography, and a /now page — all in one place, fully yours.

Fork it. Deploy to a $4/mo server. Make it yours.

<!-- [screenshot placeholder] -->

---

## Why Fieldnotes?

Most personal sites are either **static generators** that can't do anything dynamic, or **bloated platforms** that do too much and own your data.

Fieldnotes is neither. It's a full Rails application — admin panel, rich text editor, image optimization, background jobs, real-time updates — running on **one server, one SQLite file, one deploy command**. No Redis. No external JavaScript frameworks. No vendor lock-in.

You own everything. Your content lives in a single database file you can copy, back up, and move anywhere.

---

## How it compares

| | Fieldnotes | Hugo / Jekyll | WordPress | Ghost | Astro / Next.js |
|---|---|---|---|---|---|
| Admin panel | Built-in, custom | None — edit files only | Yes, bloated | Yes, SaaS ($9+/mo) | None or build your own |
| Rich text editor | Lexxy (Lexical-based) | Markdown files | Gutenberg | Proprietary | Depends on CMS |
| Image optimization | AVIF/WebP pipeline, automatic | Manual | Plugins, fragile | Limited | Manual or paid service |
| Background jobs | Solid Queue (built-in) | Not possible | wp-cron (unreliable) | Not possible | External service needed |
| Real-time features | Solid Cable (WebSockets) | Not possible | Plugins | Limited | External service needed |
| Database | SQLite — one file, full ownership | Flat files | MySQL — complex backups | MySQL | Depends |
| Hosting cost | **$4/mo** (any VPS) | Free (GitHub Pages) | $4–25/mo | $9–25/mo | $0–20/mo (Vercel) |
| Data export | Full ZIP (JSON + files) | Git repo is the export | XML, incomplete | JSON | No standard |
| Privacy | **Zero trackers, zero third-party requests** | Depends on theme | Plugins phone home | Some tracking | Depends |
| Self-hosted | Yes, always | Yes (with CI/CD) | Yes, but complex | Possible, complex | Possible, complex |
| Dependencies | Ruby + SQLite | Go or Ruby | PHP + MySQL + plugins | Node + MySQL | Node + dozens of npm packages |

---

## Privacy-first by design

Fieldnotes makes zero third-party requests. None.

- **No Google Fonts** — typography is self-hosted (Onest + JetBrains Mono, `.woff2` files in the repo)
- **No analytics scripts** — page views tracked server-side via `Rails.event.notify`, stored in your SQLite
- **No CDN dependencies** — icons, fonts, and all assets served from your server
- **No cookie banners needed** — because there are no tracking cookies
- **Full data export** — download everything as a ZIP archive (JSON data + original files) from the admin panel

Your readers get a fast, clean experience. No consent popups. No surveillance.

---

## What's inside

### Core modules (always included)

**Essays** — long-form writing with rich text (Lexxy editor), cover images, human-readable slugs (`/essays/rails-sqlite-production`), Markdown export (`/essays/:slug.md`), full-text RSS.

**Now** — what you're doing right now, in the [nownownow.com](https://nownownow.com) tradition. Version history built-in — readers can see how your focus evolves.

### Optional modules (enable what you need)

**Projects** — portfolio with status tracking (active, paused, completed, abandoned), links to repos and live sites, stack tags.

**Reading** — public reading log. Not a Goodreads clone. The core is one field: `key_idea` — what did you take away from this book? Covers fetched automatically from Open Library (free, no API key).

**Craft** — photo and video series for people who make things with a camera. AVIF/WebP optimization pipeline, watermarking, YouTube facade pattern (privacy-respecting embeds via `youtube-nocookie.com`).

Don't need a module? Remove the routes and nav link. No hidden dependencies between modules.

---

## Tech stack

Everything built-in. Minimal external dependencies.

| | |
|---|---|
| **Ruby 4.0.1** | Latest Ruby with PRISM parser and YJIT (~15-20% performance boost in production) |
| **Rails 8.1** | Solid Queue, Solid Cache, Solid Cable — background jobs, caching, and WebSockets with zero external services |
| **SQLite** | Production database. WAL mode. One file. Backup = copy. |
| **Lexxy** | Next-generation rich text editor from 37signals, built on Meta's Lexical |
| **Kamal 2** | Zero-downtime deploys to any VPS. SSL automatic via Let's Encrypt. |
| **Propshaft + Importmaps** | No Node.js, no Webpack, no Vite, no npm. Asset pipeline that just works. |
| **Active Storage + libvips** | Automatic AVIF/WebP image variants. Background processing. No cloud services needed. |

---

## Quick start

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USER/fieldnotes.git
cd fieldnotes
mise install        # installs Ruby 4.0.1
bin/setup           # installs gems, creates database
bin/dev             # starts the server
```

Open http://localhost:3000 — done.

See [docs/getting-started.md](docs/getting-started.md) for detailed instructions including prerequisites and admin setup.

---

## Deploy

```bash
kamal setup    # first deploy — server, Docker, SSL, everything
kamal deploy   # subsequent deploys — zero downtime
```

Target: **Hetzner CX22** — $4.51/mo, 2 vCPU, 4GB RAM, 40GB disk. Enough for years of content and ~10,000 photos.

See [docs/deployment.md](docs/deployment.md) for a step-by-step guide from zero (no server, no domain) to production.

---

## Rails 8 features showcased

Fieldnotes exists partly to demonstrate what Rails 8 can do out of the box:

- **Solid Queue** — background jobs without Redis
- **Solid Cache** — caching without Redis or Memcached
- **Solid Cable** — WebSockets without Redis or AnyCable
- **ActiveJob::Continuable** — data export that resumes if the server restarts mid-job
- **Built-in authentication** — no Devise, no external gem
- **rate_limit** — request throttling without Rack::Attack
- **fresh_when** — HTTP caching with ETag and Last-Modified on every page
- **format.md** — essays available as Markdown for RSS readers and AI agents
- **config/ci.rb + bin/ci** — local CI without GitHub Actions or external services
- **YJIT** — enabled in production for ~15-20% performance boost

No gem for something Rails already does.

---

## Documentation

| Guide | Description |
|---|---|
| [Getting Started](docs/getting-started.md) | Prerequisites, setup, admin account, customization |
| [Deployment](docs/deployment.md) | VPS, Kamal, SSL, secrets, backups, troubleshooting |
| [Design System](docs/design.md) | Tokens, typography, homepage layout, animations |
| [SEO & Discoverability](docs/seo.md) | JSON-LD, Open Graph, RSS, analytics, performance |
| [Image Pipeline](docs/images.md) | AVIF/WebP variants, watermarks, picture tag |
| [Rails 8 Features](docs/rails8-features.md) | Code examples for every Rails 8 feature used |
| [Data Export](docs/export.md) | ZIP archive structure and rules |
| [Open Library API](docs/open-library.md) | Book metadata and covers |
| [PWA](docs/pwa.md) | Manifest, service worker, offline support |

---

## Contributing

Contributions are welcome — especially from people running Fieldnotes for their own sites.

- See `CONTRIBUTING.md` for setup, code style, and PR process
- Look for issues tagged **good first issue**
- Bug reports and Lexxy compatibility fixes are especially valuable
- We write tests before code — no PR is merged without tests

---

## Philosophy

Fieldnotes is built on a few beliefs:

1. **You should own your platform.** Not rent it from a SaaS. Not depend on a company's pricing decisions. One SQLite file, one server, full control.

2. **Personal sites should be personal.** No templates that look like everyone else's. Hand-crafted CSS, self-hosted fonts, your voice in every line.

3. **Privacy is not a default — it's the only option.** Zero third-party requests. No Google Fonts. No analytics scripts. No tracking cookies. Your readers deserve respect.

4. **Rails is enough.** You don't need a JavaScript framework, a headless CMS, a managed database, and five microservices to run a personal site. You need Rails, SQLite, and a $4 server.

---

## License

MIT — use it however you want.

Built with Rails 8.1, Ruby 4, and stubbornness.
