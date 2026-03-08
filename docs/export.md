# Data Export

Admin panel: "Export all data" button → ZIP archive via `ExportJob`.
Delivered via Turbo Stream notification with download link (expires 24h).

---

## ZIP Structure

```
fieldnotes-export-YYYY-MM-DD/
├── data/
│   ├── essays.json
│   ├── projects.json
│   ├── books.json
│   ├── craft_series.json
│   ├── craft_items.json
│   ├── now_entries.json
│   └── tags.json
├── files/
│   ├── essays/covers/
│   ├── craft/photos/
│   └── projects/covers/
└── README.md          # documents JSON format for importers
```

---

## Rules

- All models exported — full ownership, not selective
- JSON fields match column names exactly (no camelCase)
- Files exported as originals from Active Storage (not WebP variants)
- Archive attached to Active Storage, link expires after 24 hours
- One export at a time — enqueue only if no pending `ExportJob` exists
- `ExportJob` uses `ActiveJob::Continuable` — see `docs/rails8-features.md`
