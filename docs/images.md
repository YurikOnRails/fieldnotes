# Image Optimization Pipeline

All photos: AVIF → WebP → JPEG. Never serve raw uploads. Never generate variants inline.

---

## Variants

```ruby
# Same set for field_items, essay covers, build covers
VARIANTS = {
  thumb:  { resize_to_fill:  [400, 300],   format: :avif, saver: { quality: 75 } },
  medium: { resize_to_limit: [800, 600],   format: :avif, saver: { quality: 80 } },
  full:   { resize_to_limit: [1920, 1080], format: :avif, saver: { quality: 85 } },
  hero:   { resize_to_fill:  [1600, 900],  format: :avif, saver: { quality: 85 } }
}
```

Warmed by `ImageVariantJob` after upload. Never call `.variant()` inline in views.

---

## picture tag (always use this, never plain image_tag for photos)

```erb
<picture>
  <source
    srcset="<%= url_for(photo.variant(format: :avif, resize_to_limit: [400, 300])) %> 400w,
            <%= url_for(photo.variant(format: :avif, resize_to_limit: [800, 600])) %> 800w,
            <%= url_for(photo.variant(format: :avif, resize_to_limit: [1600, 1200])) %> 1600w"
    type="image/avif">
  <source
    srcset="<%= url_for(photo.variant(format: :webp, resize_to_limit: [400, 300])) %> 400w,
            <%= url_for(photo.variant(format: :webp, resize_to_limit: [800, 600])) %> 800w,
            <%= url_for(photo.variant(format: :webp, resize_to_limit: [1600, 1200])) %> 1600w"
    type="image/webp">
  <%= image_tag photo.variant(resize_to_limit: [800, 600]),
      loading: "lazy",
      sizes: "(max-width: 768px) 100vw, 50vw",
      alt: item.caption %>
</picture>
```

`loading="lazy"` everywhere except first visible hero image — use `loading="eager"` there.

---

## Blur-up loading (reveal_controller handles fade, blur_up_controller handles swap)

```javascript
// app/javascript/controllers/blur_up_controller.js
export default class extends Controller {
  static targets = ["thumb", "full"]

  connect() {
    const img = new Image()
    img.src = this.fullTarget.dataset.src
    img.onload = () => {
      this.fullTarget.src = img.src
      this.thumbTarget.classList.add("opacity-0", "transition-opacity")
    }
  }
}
```

---

## Watermark (field_items photos only)

Pipeline: `Original (stored clean) → watermark applied in-memory → AVIF/WebP variants`

```ruby
# Inside ImageVariantJob
def apply_watermark(image)
  watermark = Vips::Image.new_from_file(
    Rails.root.join("app/assets/images/watermark.png").to_s
  )
  scale     = (image.width * 0.12) / watermark.width
  watermark = watermark.resize(scale)
  left = image.width  - watermark.width  - 24
  top  = image.height - watermark.height - 24
  image.composite(watermark, :over, x: left, y: top)
end
```

- `watermark.png`: transparent background, ~200×40px, at `app/assets/images/watermark.png`
- Opacity 40% (pre-multiplied alpha in PNG)
- If file missing: skip silently, log warning, continue

| Attachment | Watermark |
|---|---|
| `field_items` photos | yes |
| `essays` covers | optional |
| `books` covers | no (third-party) |
| Admin previews | no |

---

## Expected sizes

| Original | AVIF 1920px | WebP 1920px |
|---|---|---|
| JPEG 4MB | ~180KB | ~280KB |
| Page with 12 photos | ~2MB total | — |
