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
  --color-bg:           #0F0F0F;
  --color-surface:      #1A1A1A;
  --color-border:       #2E2E2E;
  --color-text:         #E8E3DC;
  --color-muted:        #888780;
  --color-accent:       #E8722A;
  --color-accent-hover: #F08040;

  --font-sans: 'Onest', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --text-base: 1.125rem;
  --leading:   1.8;

  --space-1:  0.25rem;
  --space-2:  0.5rem;
  --space-3:  0.75rem;
  --space-4:  1rem;
  --space-6:  1.5rem;
  --space-8:  2rem;
  --space-12: 3rem;
  --space-16: 4rem;

  --width-content: 70ch;
  --width-wide:    90rem;

  --radius-card: 6px;
  --radius-btn:  999px;

  --shadow-card:  0 1px 3px rgba(0,0,0,0.4), 0 4px 12px rgba(0,0,0,0.3);
  --shadow-hover: 0 4px 8px rgba(0,0,0,0.5), 0 12px 24px rgba(0,0,0,0.4);

  --transition: 200ms ease;
}
```

---

## Rules

- **Dark background** — `#0F0F0F` with `#1A1A1A` card surfaces. Deep but not pure black — pure black is harsh. The slight lift gives depth without blinding contrast.
- **Navigation: emoji + text label** (`✍️ Essays`) — human, readable, zero icon dependency. Icons without text are puzzles.
- **Card hover: `translateY(-2px)` + `--shadow-hover`** — pure CSS, no JS. If you need JavaScript to do a hover effect, you've lost the plot.
- **Body text: 18–21px, 60–75 chars/line** — readable prose, not a mobile app. Mobile-first layout.
- **Buttons: pill shape** (`border-radius: 999px`), accent fill for primary CTA — friendly, not corporate.
- **Icons: Unicode emoji for nav · [Phosphor Icons](https://phosphoricons.com/) SVG sprite for UI chrome** (MIT, multi-weight: `light` for decorative, `bold` for functional). Self-hosted. No CDN.
- **Personal voice in every line** — not corporate language, not generic filler. Every heading should sound like a human wrote it.
- **F-pattern: key words first** in every heading — readers scan, not read.
- **Dark-first, single theme** — no toggle, no `prefers-color-scheme` switching. One design, done well. Orange accent (`#E8722A`) provides warmth against the dark canvas.
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
