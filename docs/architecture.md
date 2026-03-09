# Architecture & Philosophy

Why this codebase is built the way it is.

---

## Majestic Monolith

One app. One database. One server. One deploy. No microservices, no queues in the cloud, no managed databases, no Kubernetes. Ship something beautiful and own it completely.

Rails omakase — the chef has chosen the ingredients, don't swap them out. When Rails gives you something, use it. When a gem offers what Rails already does, delete the gem. When a framework offers what vanilla HTML+CSS does, delete the framework.

## Why SQLite

Not because we couldn't afford Postgres. Because SQLite is the right tool for a personal site. It's faster for reads, simpler to operate, and trivially backed up with `cp`. Litestack provides jobs, cache, and websockets on top of it — no external services needed.

## HTML Over the Wire

Turbo makes pages feel instant. Stimulus adds just enough JS where behavior is needed. The browser is not a runtime for a JavaScript application — it's a document viewer that happens to support interactivity.

---

## Content Modules

Essays and /now are the soul of this app. Everything else is optional.
Disable optional modules by removing routes, nav links, and admin controllers. Don't leave dead code.

| Module | Core? | Notes |
|---|---|---|
| Essays | yes | |
| Now | yes | Multiple records = natural history; show latest + archive |
| Builds | optional | Card grid catalog: businesses, OSS, channels, key links |
| Books | optional | `key_idea` field is the point, not a Goodreads clone |
| Field | optional | Photo/video expedition series with AVIF pipeline and watermarks |

---

## What We're Not Building (and why)

Every "no" is deliberate. Features have carrying costs. Complexity compounds.

- **No comments** — the internet doesn't need another comment section
- **No search** — good navigation and RSS make search unnecessary at this scale
- **No payments** — keep money out of v1
- **No `/pulse` dashboard** — vanity metrics in real-time (v2, see `docs/pulse.md`)
- **No `/map`** — coordinates are being collected now; the map comes later (v3)
- **No Web Push** — nobody needs another notification
- **No multi-user** — this is a personal site, not a platform
- **No newsletter/email** — RSS is the original subscribe
- **No bidirectional links / graph view** — reconsider at 200+ essays; premature until then
- **No AI-generated content** — this app exists to publish a human voice, not simulate one
- **No Webmentions, WebSub** — IndieWeb complexity that serves nobody reading this site
- **No JS UI libraries** — not Preline, not Alpine, not anything. Stimulus is the ceiling.

---

## On Dependencies

When tempted to add a gem, ask:

1. Does Rails already do this?
2. Can I write this in under 30 lines?
3. Is this gem actively maintained and trusted?

If Rails does it, use Rails. If you can write it, write it. Only reach for a gem when the answer to both is no and the alternative is genuinely worse.

---

## Less Software

The best code is code you didn't write. Before adding a feature, ask whether removing something achieves the same goal. Beautiful code matters — not clever, not terse. Code that reads like prose and does exactly what it says.
