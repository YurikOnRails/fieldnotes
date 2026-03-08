# Design System

Reference aesthetic: Basecamp — warm, human, content-first. Not corporate, not a template.

---

## Typography — self-hosted, no Google Fonts (privacy)

Fonts live in `app/assets/fonts/`. No CDN requests, no third-party tracking.

| Role | Font | Weights |
|---|---|---|
| Body + UI | **Onest** (supports Cyrillic + Latin) | 400, 500, 600, 700 |
| Code blocks | **JetBrains Mono** | 400, 500 |

`font-display: swap` on all `@font-face` declarations. Only `.woff2` — no other formats needed.

---

## Design Tokens (`app/assets/stylesheets/tokens.css`)

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

Animations — subtle, CSS-first:
- Fade-in on scroll via `IntersectionObserver` in Stimulus (`reveal_controller.js`)
- Hover on tiles: `scale(1.02)` + shadow — pure CSS, no JS
- Typewriter effect in hero tagline — one line, `typewriter_controller.js`
- No parallax, no animation libraries (GSAP etc.), no spinning elements
