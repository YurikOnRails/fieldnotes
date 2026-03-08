# Open Library API — Books Metadata

Fetches book cover and metadata by ISBN. Free, no API key.

- **Docs:** https://openlibrary.org/developers/api
- **Cover URL:** `https://covers.openlibrary.org/b/isbn/{ISBN}-L.jpg`
- **Metadata:** `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`

---

## Service

```ruby
# app/services/open_library_service.rb
# Usage:
book_data = OpenLibraryService.fetch(isbn: "9780316769174")
# => { title:, author:, cover_url:, year: }
```

- Cache results in Solid Cache for **7 days** — metadata rarely changes
- Store `cover_url` as plain string on `books` table — no Active Storage for book covers
- Graceful fallback: show placeholder cover on API failure, never raise
