# SEO & Discoverability

The site must be easily found by humans (Google) and machines (AI agents, RSS readers).
No external services. No JS trackers. Just standard web protocols done right.

---

## Checklist

| Feature | Implementation | Why |
|---|---|---|
| `sitemap.xml` | Auto-generated, cached 1h. Essays, builds, field, static pages | Google indexing — table stakes |
| JSON-LD | `Article` on essays, `Person` on /about, `Book` on /books, `CreativeWork` on builds | Rich snippets in search results |
| Open Graph + Twitter meta | `og:title`, `og:description`, `og:image` on every public page | Beautiful previews when shared on Telegram, Twitter, LinkedIn |
| `llms.txt` | Static file in `public/` — who you are, what's on the site, useful endpoints | AI agent discoverability (llmstxt.org) — one file, zero maintenance |
| Full-text RSS | `/feed.rss` (all content), `/essays.rss` | Loyal readers. RSS audience = exact target demographic |
| `format.md` | `/essays/:slug.md` — already in Rails 8 features | CLI tools, AI agents, RSS readers that prefer plain text |
| Canonical URLs | `<link rel="canonical">` on every page | Prevent duplicate content in search |

---

## Meta tags — ViewComponent

```ruby
# app/components/meta_tags_component.rb
# Renders <title>, description, OG tags, JSON-LD in <head>
# Every public controller sets @meta via a simple hash
```

---

## llms.txt

```text
# public/llms.txt
# Fieldnotes — personal site & digital garden
# Author: [Your Name]
# Stack: Rails 8.1, Ruby 4, SQLite
# Essays: /essays (HTML), /essays/:slug.md (Markdown), /essays.rss (RSS)
# Builds: /builds
# Books: /books
# Contact: /contact
```

---

## RSS

Full-text RSS — never excerpts. Respect the reader.

```ruby
# Responds to .rss via respond_to in controllers
# /feed.rss     — unified feed (all content types)
# /essays.rss   — essays only
# /builds.rss  — builds only
```

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

## Analytics (Rails.event.notify)

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
- AVIF → WebP → JPEG pipeline via `<picture>` tag. See [`images.md`](images.md)
- Open Library API results cached 7 days. See [`open-library.md`](open-library.md)
