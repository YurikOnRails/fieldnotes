# Deployment — from zero to production

One VPS, one command, your site is live. Total cost: ~$4/mo + domain (~$10/year).

**What you need before starting:**
- Local setup working (`bin/dev` runs, admin panel works) — see [`getting-started.md`](getting-started.md)
- A domain name (any registrar: Namecheap, Cloudflare, Porkbun, etc.)
- 30–45 minutes for first deploy

---

## Step 1: Create a GitHub token for container registry

Your Docker images will be stored on **GitHub Container Registry (ghcr.io)** — free, no extra accounts.
You already have a GitHub account (you forked the repo), so this takes 2 minutes.

1. Go to https://github.com/settings/tokens?type=beta → **Generate new token**
2. Name: "fieldnotes deploy"
3. Expiration: **90 days** (or "No expiration" if you prefer — you can revoke anytime)
4. Repository access: **Only select repositories** → pick your fieldnotes fork
5. Permissions → **Packages**: Read and write
6. Click **Generate token**
7. **Copy the token** — you'll need it in Step 4. You won't see it again.

---

## Step 2: Rent a VPS

Recommended: **Hetzner CX22** — 2 vCPU, 4GB RAM, 40GB disk, $4.51/mo.

1. Sign up at https://console.hetzner.cloud
2. Create a new project → **Add Server**
3. Location: pick nearest to your audience
4. Image: **Ubuntu 24.04**
5. Type: **CX22** (shared vCPU, 2 cores, 4GB RAM)
6. SSH Key — you must add one:

**If you don't have an SSH key yet:**

```bash
# Run on your local machine (not the server)
ssh-keygen -t ed25519 -C "your@email.com"
# Press Enter for default location, set a passphrase or leave empty
cat ~/.ssh/id_ed25519.pub
# Copy the output — this is your public key
```

Paste the public key into Hetzner's "SSH Key" field during server creation.

7. Click **Create & Buy Now**
8. Note the server's **IP address** (shown after creation)

**Verify SSH works:**

```bash
ssh root@YOUR_SERVER_IP
# Should connect without password. Type "exit" to disconnect.
```

---

## Step 3: Point your domain to the server

Go to your domain registrar's DNS settings and add:

```
Type: A
Name: @ (or your subdomain, e.g. "notes")
Value: YOUR_SERVER_IP
TTL: 300
```

**Verify DNS (wait 5–10 minutes first):**

```bash
dig +short yourdomain.com
# Should show YOUR_SERVER_IP
```

---

## Step 4: Configure Kamal

Edit `config/deploy.yml` in your local repo — replace all placeholders:

```yaml
service: fieldnotes
image: ghcr.io/YOUR_GITHUB_USER/fieldnotes

servers:
  web:
    hosts:
      - YOUR_SERVER_IP

proxy:
  ssl: true
  host: yourdomain.com

registry:
  server: ghcr.io
  username: YOUR_GITHUB_USER
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

Replace `YOUR_GITHUB_USER` with your GitHub username (lowercase). Example: `ghcr.io/johndoe/fieldnotes`.

---

## Step 5: Set up secrets

```bash
# Create the secrets file
mkdir -p .kamal
```

Generate the values you need:

```bash
bin/rails secret
# Copy the long string — this is your SECRET_KEY_BASE

cat config/master.key
# Copy the short string — this is your RAILS_MASTER_KEY
# (if this file doesn't exist, run: bin/rails credentials:edit)
```

Create `.kamal/secrets` with your values:

```bash
KAMAL_REGISTRY_PASSWORD=your_github_token_from_step_1
SECRET_KEY_BASE=the_long_string_you_just_generated
RAILS_MASTER_KEY=the_short_string_from_master_key
```

**Important:** `.kamal/secrets` is in `.gitignore` — it will NOT be committed. This is correct.

---

## Step 6: Deploy

```bash
# First deploy — installs Docker on server, builds image, starts everything
kamal setup
```

This takes 5–10 minutes on first run. It will:
- Install Docker on your server (automatic)
- Build your Rails app into a Docker image
- Push the image to GitHub Container Registry
- Pull it on the server and start it
- Set up SSL via Let's Encrypt (automatic)

**Verify:**

```bash
curl -I https://yourdomain.com
# Should return: HTTP/2 200
```

Open https://yourdomain.com in your browser. Your site is live.

---

## Step 7: Create admin user on production

```bash
kamal app exec 'bin/rails console'
```

```ruby
User.create!(email_address: "you@example.com", password: "your_secure_password")
exit
```

Admin panel: https://yourdomain.com/admin

---

## Updating your site

After making changes locally:

```bash
git add -A && git commit -m "your changes"
kamal deploy    # builds, pushes, deploys — zero downtime
```

### Clean up old images on ghcr.io

GitHub Container Registry free tier gives you 500 MB. One Rails image is ~300–400 MB,
so old versions pile up fast. Clean up after each deploy:

```bash
# Install GitHub CLI if you don't have it: https://cli.github.com
# Delete all untagged (old) image versions:
gh api user/packages/container/fieldnotes/versions --paginate --jq '.[].id' | \
  xargs -I {} gh api --method DELETE user/packages/container/fieldnotes/versions/{}
```

Or add this as a one-liner after deploy:

```bash
kamal deploy && gh api user/packages/container/fieldnotes/versions \
  --paginate --jq '.[] | select(.metadata.container.tags | length == 0) | .id' | \
  xargs -I {} gh api --method DELETE user/packages/container/fieldnotes/versions/{}
```

This keeps only the latest tagged image and removes untagged leftovers.

---

## Backups

Your database is a single SQLite file. Back it up daily:

```bash
# Download a backup to your local machine
kamal app exec 'sqlite3 /rails/db/production.sqlite3 ".backup /tmp/backup.sqlite3"'
kamal app exec 'cat /tmp/backup.sqlite3' > backup-$(date +%Y%m%d).sqlite3
```

Run this weekly at minimum. Store backups somewhere safe (another machine, cloud storage).

---

## SQLite in production — why it works

- Single server, single writer — no contention
- WAL mode (Rails 8 default) — reads don't block writes
- Solid Queue, Cache, Cable all use SQLite — zero external dependencies
- Handles thousands of daily visitors easily
- Backup = copy one file

---

## Storage limits

| Content | Avg size (AVIF) | Fits in 40GB |
|---|---|---|
| Essay covers | ~200KB | ~200,000 images |
| Craft photos | ~535KB | ~74,000 photos |
| Typical use | mixed | Years of content |

If you need more: Hetzner allows live disk resize, or switch Active Storage to S3-compatible.

---

## Troubleshooting

| Problem | What to do |
|---|---|
| `kamal setup` fails with SSH error | Run `ssh root@YOUR_IP` manually — if that fails, check your SSH key |
| `kamal setup` fails at Docker build | Check `Dockerfile` — ensure libvips is listed in apt packages |
| SSL not working | DNS not propagated yet. Wait 10 min, verify with `dig yourdomain.com` |
| 502 Bad Gateway after deploy | `kamal app logs` — usually a missing secret in `.kamal/secrets` |
| Site works but images broken | Run `kamal app exec 'bin/rails console'` and warm variants manually |
| "Database locked" errors | Check that only one web process is running: `kamal app containers` |
| Forgot admin password | `kamal app exec 'bin/rails console'` → `User.first.update!(password: "newpass")` |
