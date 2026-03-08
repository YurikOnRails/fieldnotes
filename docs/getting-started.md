# Getting Started

Fork → clone → run locally. No Redis, no PostgreSQL, no Node.js, no Yarn.

---

## 1. Fork the repository

Go to the Fieldnotes repo on GitHub → click **Fork** (top right) → this creates your own copy.

Then clone your fork:

```bash
git clone https://github.com/YOUR_GITHUB_USER/fieldnotes.git
cd fieldnotes
```

---

## 2. Install prerequisites

### macOS

```bash
brew install mise vips sqlite
```

### Ubuntu / Debian

```bash
# mise
curl https://mise.jdx.dev/install.sh | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# system libraries
sudo apt update
sudo apt install -y libvips-dev libsqlite3-dev build-essential
```

### Verify

```bash
mise --version    # should print version
vips --version    # should print 8.15+
sqlite3 --version # should print 3.45+
```

---

## 3. Install Ruby and dependencies

```bash
mise install          # installs Ruby 4.0.1 from .mise.toml
bin/setup             # installs gems, creates database, prepares assets
```

**If `bin/setup` fails:**
- `Could not find gem` → run `gem install bundler` then `bin/setup` again
- `vips/vips.h not found` → libvips not installed (see step 2)
- `sqlite3.h missing` → install `libsqlite3-dev` (Ubuntu) or `sqlite` (macOS)

---

## 4. Start the development server

```bash
bin/dev
```

Open http://localhost:3000 — you should see the homepage.

---

## 5. Create your admin account

Option A — seed file (easiest):

```bash
bin/rails db:seed
# Creates admin@example.com / password: "changeme"
# Change these in db/seeds.rb before running
```

Option B — Rails console:

```bash
bin/rails console
```

```ruby
User.create!(email_address: "you@example.com", password: "your_secure_password")
exit
```

Admin panel: http://localhost:3000/admin

---

## 6. Make it yours

| What | How |
|---|---|
| Content | Add essays, projects, books via admin panel |
| Colors & spacing | Edit `app/assets/stylesheets/tokens.css` |
| Fonts | Swap `.woff2` files in `app/assets/fonts/`, update `@font-face` |
| Hero photo | Upload via admin panel |
| Watermark | Replace `app/assets/images/watermark.png` |
| PWA icons | Replace `public/icons/icon-192.png` and `icon-512.png` |
| Site name | Search for "Fieldnotes" in views and replace with your name |

---

## Key commands

```bash
bin/dev              # Start dev server (Rails + Solid Queue)
bin/ci               # Run full test suite
bin/rails test       # Unit + controller tests only
bin/rails console    # Interactive Ruby console
bin/rails db:seed    # Create initial admin user
```

---

## Next step

Ready to go live? See [`deployment.md`](deployment.md) — full guide from zero to production.
