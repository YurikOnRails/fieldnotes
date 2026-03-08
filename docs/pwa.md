# PWA — Progressive Web App

Rails 8 generates PWA files automatically. Fieldnotes is installable as a standalone app.

---

## Files (Rails 8 scaffold, already present)

```
app/views/pwa/manifest.json.erb
app/views/pwa/service_worker.js
public/icons/icon-192.png
public/icons/icon-512.png
```

Icons generated from single SVG via vips (already installed for Active Storage):
```bash
vips thumbnail icon.svg icon-192.png 192
vips thumbnail icon.svg icon-512.png 512
```

---

## manifest.json.erb

```json
{
  "name": "Fieldnotes",
  "short_name": "Fieldnotes",
  "description": "A personal site & digital garden",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FAF9F7",
  "theme_color": "#FAF9F7",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## service_worker.js

```javascript
const CACHE = "fieldnotes-v1"
const OFFLINE_URLS = ["/", "/essays", "/offline"]

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(OFFLINE_URLS))
  )
})

self.addEventListener("fetch", event => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
      .catch(() => caches.match("/offline"))
  )
})
```

Add `/offline` route + `public/offline.html`: logo, message, list of cached essays.

---

## Rules

- Increment `CACHE` version on breaking deploys to force cache refresh
- Do NOT cache admin routes — offline mode for public readers only
- Test: Chrome DevTools → Application → Manifest
