# Admin user — idempotent, safe to re-run
email    = ENV.fetch("ADMIN_EMAIL",    "admin@example.com")
password = ENV.fetch("ADMIN_PASSWORD", "changeme123!")

user = User.find_or_initialize_by(email_address: email)
user.password = password if user.new_record?
user.save!

puts "Admin user ready: #{user.email_address}"

# ─── Essays ────────────────────────────────────────────────────────────────────

essays = [
  {
    title: "SQLite in Production Is Fine, Actually",
    slug: "sqlite-in-production-is-fine-actually",
    excerpt: "After running SQLite on a busy Rails app for six months, I have some thoughts on when it's the right call and when it isn't.",
    status: "published",
    published_at: 3.weeks.ago,
    location_name: "Berlin, Germany",
    latitude: 52.5200,
    longitude: 13.4050,
    content: <<~HTML
      <p>Everyone told me not to do it. "SQLite doesn't scale," they said. "You'll regret it." Six months later, the app is handling 40k requests per day with p99 latency under 20ms and I've touched the database layer exactly twice.</p>
      <h2>What actually happens under load</h2>
      <p>SQLite uses WAL mode by default in Rails 8 via Litestack. WAL means readers and writers don't block each other, which covers 95% of web application access patterns. Concurrent writes are serialized — but if you have so many concurrent writes that this matters, you have a good problem and more money than you started with.</p>
      <p>The single-file nature is a feature, not a bug. Backups are <code>cp app.db app.db.bak</code>. Migrations run in milliseconds. There's no connection pool to manage, no network round-trips to a separate server.</p>
      <h2>Where it breaks down</h2>
      <p>Reporting queries that would benefit from read replicas. Multi-region deployments where writes need to happen close to the user. Anything that requires row-level locking. These are real constraints — they just don't apply to most applications most of the time.</p>
      <p>Start with SQLite. Migrate when you have evidence you need to, not because a Reddit thread told you to.</p>
    HTML
  },
  {
    title: "The Case for Boring Technology",
    slug: "the-case-for-boring-technology",
    excerpt: "New is exciting. Boring is reliable. Most production systems should be boring.",
    status: "published",
    published_at: 6.weeks.ago,
    location_name: "Tbilisi, Georgia",
    latitude: 41.6938,
    longitude: 44.8015,
    content: <<~HTML
      <p>Dan McKinley's classic essay on choosing boring technology made the rounds again last week. Every time it surfaces, I see the same replies: "But what about performance?" "But what about developer experience?" Missing the point entirely.</p>
      <p>The argument isn't that new technology is bad. It's that every technology choice comes with an innovation token budget, and most teams have fewer tokens than they think.</p>
      <h2>What boring actually means</h2>
      <p>Boring means understood. It means the failure modes are known, the operations runbook exists, the Stack Overflow answers are there when you need them at 2am. Boring means your team can hire for it, onboard quickly, and reason about problems without reading source code.</p>
      <p>Exciting technology means none of that. You're paying for novelty with operational risk, hiring difficulty, and accumulated tribal knowledge that walks out the door when someone leaves.</p>
      <h2>The real calculation</h2>
      <p>Use new technology when the specific capabilities justify the cost. A graph database for a genuinely graph-shaped problem. Rust for a component where performance is the product. Otherwise, reach for the boring option and spend your innovation tokens on the actual problems your users have.</p>
    HTML
  },
  {
    title: "How I Structure a Rails Application in 2026",
    slug: "how-i-structure-rails-app-2026",
    excerpt: "Conventions are load-bearing. Here's the structure I keep coming back to after building a dozen Rails apps.",
    status: "published",
    published_at: 2.months.ago,
    location_name: "Lisbon, Portugal",
    latitude: 38.7169,
    longitude: -9.1399,
    content: <<~HTML
      <p>Rails gives you a lot of structure for free. After building a dozen apps of varying sizes, I've settled into a set of conventions that I reach for before writing any code.</p>
      <h2>Namespace admin from day one</h2>
      <p>Even the simplest CRUD app eventually needs an admin interface. If you start with a flat controller structure, you'll spend a week untangling it later. Start with <code>Admin::BaseController</code> and namespace everything behind authentication from the first commit.</p>
      <h2>Concerns are fine, actually</h2>
      <p>The Rails community went through a phase of hating concerns. Service objects, interactors, operation objects — all valid patterns that add indirection. Concerns are just modules. They're the right tool for shared model behavior like <code>Sluggable</code> or <code>Taggable</code>. Don't overcomplicate it.</p>
      <h2>One job per model relationship</h2>
      <p>If you're doing more than one thing in an after_create callback, extract a job. Callbacks that send emails, update caches, and notify webhooks are a maintenance nightmare. Jobs are explicit, retriable, and testable in isolation.</p>
      <p>That's mostly it. The Rails conventions are good. Resist the urge to add abstractions until the pain of not having them is obvious.</p>
    HTML
  },
  {
    title: "Notes on Walking in Cities",
    slug: "notes-on-walking-in-cities",
    excerpt: "Walking is the best way to understand a city. A few things I've noticed after doing a lot of it.",
    status: "published",
    published_at: 10.weeks.ago,
    content: <<~HTML
      <p>I try to walk everywhere when I'm in a new city. Not for the exercise — for the texture. Maps flatten everything into the same scale. Walking forces you to feel the gradient between neighborhoods, the way a city transitions from residential to commercial to industrial without announcing it.</p>
      <p>Berlin has the best walking of any city I've spent time in. The blocks are large enough that each one feels like its own world. You can walk for an hour without repeating a storefront or seeing the same kind of building twice. The history is written into the urban fabric in a way that you only notice on foot — a sudden gap where a building used to be, a different window style that marks the old dividing line.</p>
      <p>Tbilisi surprised me. The old town is one of the few places I've been where the tourist district and the actual neighborhood occupied the same streets. The cafes serving khachapuri at 8am to construction workers are the same cafes serving natural wine to digital nomads at 8pm. That kind of integration is rarer than it should be.</p>
      <p>The thing walking teaches you that nothing else can: a city's real scale. Everything feels much smaller on foot than it looks on a map. Problems that seem geographically distant turn out to be a twenty-minute walk. That changes how you think about what's possible.</p>
    HTML
  },
  {
    title: "Draft: On Writing in Public",
    slug: "on-writing-in-public",
    excerpt: "Some thoughts I'm still working through about why I find it hard to publish and what to do about it.",
    status: "draft",
    content: <<~HTML
      <p>This is a draft. I'm not sure what I want to say here yet. Something about the gap between the writing I do privately and the writing I'm willing to put my name on.</p>
      <p>The private writing is looser, faster, more exploratory. It makes claims I'm not confident in. The public writing gets edited down until all the rough edges are gone, and sometimes the interesting parts go with them.</p>
    HTML
  }
]

essays.each do |attrs|
  content = attrs.delete(:content)
  essay = Essay.find_or_initialize_by(slug: attrs[:slug])
  essay.assign_attributes(attrs)
  essay.content = content if essay.new_record? || essay.content.to_plain_text.blank?
  essay.save!
  print "."
end
puts "\nEssays: #{Essay.count}"

# ─── Now ───────────────────────────────────────────────────────────────────────

now_entries = [
  {
    published_at: 2.weeks.ago,
    body: <<~HTML
      <p>Based in Berlin for the next month. Working on Fieldnotes and a few consulting projects. Trying to write more and ship faster.</p>
      <p>Reading: Finite and Infinite Games by James Carse. Walking a lot. Drinking too much coffee at Bonanza.</p>
      <p>Currently interested in: SQLite as a production database, the Lexical editor ecosystem, and whether personal blogs are having a genuine moment or if I'm just in a filter bubble of people who think they are.</p>
    HTML
  },
  {
    published_at: 3.months.ago,
    body: <<~HTML
      <p>Just got back from three weeks in Georgia (the country). Tbilisi is extraordinary. I'll write more about it eventually.</p>
      <p>Back in Lisbon now. Catching up on email and trying to get back into a writing rhythm after traveling.</p>
    HTML
  }
]

now_entries.each do |attrs|
  body = attrs.delete(:body)
  entry = NowEntry.find_or_initialize_by(published_at: attrs[:published_at])
  entry.body = body if entry.new_record? || entry.body.to_plain_text.blank?
  entry.save!
  print "."
end
puts "\nNow entries: #{NowEntry.count}"

# ─── Builds ────────────────────────────────────────────────────────────────────

builds = [
  {
    title: "Fieldnotes",
    slug: "fieldnotes",
    description: "This site. A personal publishing platform built with Rails 8, SQLite, and Lexxy. No ads, no tracking, no VC money.",
    url: "https://fieldnotes.example.com",
    icon_emoji: "📓",
    status: "active",
    kind: "oss",
    position: 1,
    started_on: Date.new(2025, 10, 1)
  },
  {
    title: "Consultancy",
    slug: "consultancy",
    description: "Rails and infrastructure consulting for early-stage startups. Helped a dozen teams ship faster and worry less about their stack.",
    url: nil,
    icon_emoji: "🔧",
    status: "active",
    kind: "business",
    position: 2,
    started_on: Date.new(2022, 3, 1)
  },
  {
    title: "Readwise Export CLI",
    slug: "readwise-export-cli",
    description: "A small CLI tool for exporting Readwise highlights to markdown files. Built for my own workflow, open sourced because why not.",
    url: "https://github.com/example/readwise-export",
    icon_emoji: "📑",
    status: "active",
    kind: "oss",
    position: 3,
    started_on: Date.new(2024, 6, 1)
  },
  {
    title: "Heatmap Newsletter",
    slug: "heatmap-newsletter",
    description: "A weekly newsletter about interesting maps and the data behind them. Ran for two years, ~3k subscribers at peak.",
    url: nil,
    icon_emoji: "🗺️",
    status: "completed",
    kind: "media",
    position: 4,
    started_on: Date.new(2021, 1, 1),
    finished_on: Date.new(2023, 2, 1)
  },
  {
    title: "SaaS Starter",
    slug: "saas-starter",
    description: "A Rails SaaS boilerplate with auth, billing, and multi-tenancy. Built it three times before open sourcing the fourth iteration.",
    url: "https://github.com/example/saas-starter",
    icon_emoji: "🚀",
    status: "archived",
    kind: "oss",
    position: 5,
    started_on: Date.new(2023, 5, 1),
    finished_on: Date.new(2024, 8, 1)
  }
]

builds.each do |attrs|
  build = Build.find_or_initialize_by(slug: attrs[:slug])
  build.assign_attributes(attrs)
  build.save!
  print "."
end
puts "\nBuilds: #{Build.count}"

# ─── Books ─────────────────────────────────────────────────────────────────────

books = [
  {
    title: "Finite and Infinite Games",
    author: "James P. Carse",
    year_read: 2026,
    rating: 5,
    status: "reading",
    key_idea: "There are two kinds of games: finite games played to win, and infinite games played to keep playing. Most institutions confuse the two. The goal of an infinite player is not to win but to keep the play going."
  },
  {
    title: "The Dream Machine",
    author: "M. Mitchell Waldrop",
    year_read: 2025,
    rating: 5,
    status: "completed",
    key_idea: "J.C.R. Licklider invented the future of computing before the hardware existed to realize it. The lesson isn't about technology — it's about the kind of vision that can sustain a decades-long project against institutional resistance."
  },
  {
    title: "Working in Public",
    author: "Nadia Eghbal",
    year_read: 2025,
    rating: 4,
    status: "completed",
    key_idea: "Open source maintainers are content creators with the worst audience dynamics imaginable: infinite demand, no monetization, and users who confuse access to code with access to the person who wrote it."
  },
  {
    title: "A Pattern Language",
    author: "Christopher Alexander",
    year_read: 2025,
    rating: 5,
    status: "completed",
    key_idea: "Good design at every scale — from a city to a window seat — follows patterns that make humans feel alive. Software architecture borrowed the term 'design patterns' from this book and mostly missed the point."
  },
  {
    title: "The Art of Doing Science and Engineering",
    author: "Richard Hamming",
    year_read: 2024,
    rating: 4,
    status: "completed",
    key_idea: "Work on important problems. Style of thinking matters more than raw intelligence. You should be able to explain why you're working on what you're working on."
  },
  {
    title: "How Buildings Learn",
    author: "Stewart Brand",
    year_read: 2024,
    rating: 4,
    status: "completed",
    key_idea: "Buildings change over time through layers operating at different speeds. The same is true of software. Understanding which layer you're in changes how you should design."
  },
  {
    title: "The Timeless Way of Building",
    author: "Christopher Alexander",
    year_read: 2024,
    rating: 3,
    status: "abandoned",
    key_idea: "The philosophical companion to A Pattern Language. Valuable but harder going — I got what I needed and moved on."
  }
]

books.each do |attrs|
  book = Book.find_or_initialize_by(title: attrs[:title], author: attrs[:author])
  book.assign_attributes(attrs)
  book.save!
  print "."
end
puts "\nBooks: #{Book.count}"

# ─── Field ─────────────────────────────────────────────────────────────────────

field_series_data = [
  {
    title: "Tbilisi, March 2025",
    slug: "tbilisi-march-2025",
    description: "Three weeks in Georgia. Old Tbilisi, Mtatsminda, the sulfur baths, Signagi. Shot on Fuji X100VI.",
    kind: "photo",
    location: "Tbilisi, Georgia",
    taken_on: Date.new(2025, 3, 15),
    latitude: 41.6938,
    longitude: 44.8015
  },
  {
    title: "Berlin Winter 2025",
    slug: "berlin-winter-2025",
    description: "Kreuzberg and Mitte in February. Everything grey and excellent.",
    kind: "photo",
    location: "Berlin, Germany",
    taken_on: Date.new(2025, 2, 10),
    latitude: 52.5200,
    longitude: 13.4050
  },
  {
    title: "Lisbon to Porto by Train",
    slug: "lisbon-to-porto-by-train",
    description: "A long weekend on the Alfa Pendular. Station architecture, Atlantic light, tiles everywhere.",
    kind: "mixed",
    location: "Portugal",
    taken_on: Date.new(2024, 11, 20),
    latitude: 39.3999,
    longitude: -8.2245
  }
]

field_series_data.each do |attrs|
  series = FieldSeries.find_or_initialize_by(slug: attrs[:slug])
  series.assign_attributes(attrs)
  series.save!
  print "."
end
puts "\nField series: #{FieldSeries.count}"

puts "\nDone. Seed data loaded."
