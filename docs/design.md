# Design System

Design is not decoration. It's the argument you make about what matters.
Reference aesthetic: Basecamp — warm, human, content-first. Not a template, not a dashboard, not a SaaS landing page.

---

## Typography — self-hosted, no Google Fonts

Fonts live in `app/assets/fonts/`. No CDN requests. No third-party tracking. No flash of wrong font.

| Role | Font | Weights |
|---|---|---|
| Body + UI | **Onest** (supports Cyrillic + Latin) | 400, 500, 600, 700 |
| Code blocks | **JetBrains Mono** | 400, 500 |

`font-display: swap` on all `@font-face` declarations. Only `.woff2` — every browser that matters supports it, nothing else is needed.

---

## Design Tokens (`app/assets/stylesheets/tokens.css`)

One source of truth for all visual decisions. Change a token here — it changes everywhere.

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

---

## Rules

- **Warm background** — `#FAF9F7`, not pure white. Pure white is for hospitals. Cards `#FFFFFF` give gentle contrast without harshness.
- **Navigation: emoji + text label** (`✍️ Essays`) — human, readable, zero icon dependency. Icons without text are puzzles.
- **Card hover: `translateY(-2px)` + `--shadow-hover`** — pure CSS, no JS. If you need JavaScript to do a hover effect, you've lost the plot.
- **Body text: 18–21px, 60–75 chars/line** — readable prose, not a mobile app. Mobile-first layout.
- **Buttons: pill shape** (`border-radius: 999px`), accent fill for primary CTA — friendly, not corporate.
- **Icons: Unicode emoji for nav · [Phosphor Icons](https://phosphoricons.com/) SVG sprite for UI chrome** (MIT, multi-weight: `light` for decorative, `bold` for functional). Self-hosted. No CDN.
- **Personal voice in every line** — not corporate language, not generic filler. Every heading should sound like a human wrote it.
- **F-pattern: key words first** in every heading — readers scan, not read.
- **No dark mode in v1** — design with intention, not infinite toggle switches. Dark mode is a v2 decision once the light design is right.
- **No animation libraries** — no GSAP, no Framer Motion, no AOS. CSS `transition` and `transform` are enough. If it can't be done in CSS, it probably shouldn't be done.

---

## Homepage Layout

```
┌─────────────────────────────────────────────┐
│  HERO: wide portrait photo + name + tagline  │
│  (who I am, 2-3 sentences, personal voice)  │
├─────────────────────────────────────────────┤
│  Big tiles grid: Essays · Builds ·           │
│  Reading · Field · Now                      │
├─────────────────────────────────────────────┤
│  Recent: latest essay + latest project      │
└─────────────────────────────────────────────┘
```

Animations — subtle, CSS-first, purposeful:
- Fade-in on scroll via `IntersectionObserver` in Stimulus (`reveal_controller.js`)
- Hover on tiles: `scale(1.02)` + shadow — pure CSS
- Typewriter effect in hero tagline — one line, `typewriter_controller.js`
- No parallax. No spinning elements. No animations that serve the developer's ego instead of the reader's attention.
