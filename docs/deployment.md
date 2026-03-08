# Deployment — Kamal 2

One VPS. One command. Full ownership.

**Target:** Hetzner CX22 — 2 vCPU, 4GB RAM, 40GB disk, $4/mo.
Enough for ~10,000 photos (535KB avg after AVIF optimization).

---

## Server setup (one-time, ~10 minutes)

### 1. Provision a VPS

Any provider works. Recommended:
- **Hetzner CX22** ($4/mo) — best value, EU data centers
- **DigitalOcean** ($6/mo) — if you prefer US locations
- **Linode** ($5/mo) — alternative

Choose Ubuntu 24.04 LTS. Add your SSH key during creation.

### 2. Point your domain

```
A record:  fieldnotes.example.com → YOUR_SERVER_IP
```

DNS propagation takes 5–60 minutes. Verify: `dig fieldnotes.example.com`

### 3. Install Docker on the server

Kamal handles this automatically on first deploy. No manual Docker installation needed.

---

## Kamal configuration

```yaml
# config/deploy.yml
service: fieldnotes
image: your-dockerhub-user/fieldnotes

servers:
  web:
    hosts:
      - YOUR_SERVER_IP
    options:
      network: "private"

proxy:
  ssl: true
  host: fieldnotes.example.com

registry:
  username: your-dockerhub-user
  password:
    - KAMAL_REGISTRY_PASSWORD

volumes:
  - fieldnotes_storage:/rails/storage
  - fieldnotes_db:/rails/db

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: 1
  secret:
    - SECRET_KEY_BASE
    - RAILS_MASTER_KEY
```

---

## Secrets

```bash
# .kamal/secrets (local file, never commit)
KAMAL_REGISTRY_PASSWORD=your_docker_hub_token
SECRET_KEY_BASE=<output of bin/rails secret>
RAILS_MASTER_KEY=<contents of config/master.key>
```

---

## Deploy

```bash
# First deploy — sets up server, pushes image, starts containers
kamal setup

# Subsequent deploys
kamal deploy

# That's it. SSL is automatic via kamal-proxy + Let's Encrypt.
```

---

## Verify

```bash
kamal app logs          # Check Rails logs
kamal app exec 'bin/rails console'  # Remote console
curl -I https://fieldnotes.example.com  # Should return 200
```

---

## SQLite in production

SQLite lives in a Docker volume (`fieldnotes_db:/rails/db`). This survives container restarts and redeploys.

**Why SQLite works here:**
- Single server, single process writes — no write contention
- WAL mode enabled by default (Rails 8) — reads don't block writes
- Solid Queue, Solid Cache, Solid Cable all use SQLite — zero external dependencies
- Backup = copy one file

---

## Backups

```bash
# Manual backup (run from local machine)
kamal app exec 'sqlite3 /rails/db/production.sqlite3 ".backup /rails/storage/backup.sqlite3"'
kamal app exec 'cat /rails/storage/backup.sqlite3' > backup-$(date +%Y%m%d).sqlite3
```

### Automated daily backup (cron on server)

```bash
# Add to server's crontab via: kamal app exec 'crontab -e'
0 3 * * * sqlite3 /rails/db/production.sqlite3 ".backup /rails/db/backup-$(date +\%Y\%m\%d).sqlite3"
```

Keep 7 days of backups. Delete older ones to save disk space.

---

## Storage

Active Storage files live in `fieldnotes_storage:/rails/storage`.

| Content | Avg size | 40GB capacity |
|---|---|---|
| Essay covers | ~200KB (AVIF) | ~200,000 images |
| Craft photos | ~535KB (AVIF) | ~74,000 photos |
| Mixed usage | — | ~10,000 photos + years of essays |

If you outgrow 40GB: resize to a larger VPS (Hetzner allows live resize) or move Active Storage to S3-compatible storage (Hetzner Object Storage, $0.005/GB).

---

## Updating

```bash
git pull origin main    # Get latest changes
kamal deploy            # Build, push, deploy
```

Zero-downtime deploys: Kamal runs the new container, health-checks it, then stops the old one.

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Deploy fails at Docker build | Check `Dockerfile` — ensure libvips is in apt packages |
| SSL not working | Verify DNS A record points to server IP, wait for propagation |
| 502 after deploy | `kamal app logs` — likely a missing env variable |
| Database locked | Ensure only one Rails process writes; check Solid Queue isn't duplicated |
| Disk full | Check craft photos; consider S3-compatible storage |
| Slow image uploads | Normal on first upload — `ImageVariantJob` warms variants in background |
