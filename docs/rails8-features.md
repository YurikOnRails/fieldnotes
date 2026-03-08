# Rails 8 / 8.1 Features — Code Reference

Use built-in Rails solutions. This file has code examples for each feature.

---

## ActiveJob::Continuable — ExportJob

Resumes from last completed step if Kamal restarts mid-job.

```ruby
class ExportJob < ApplicationJob
  include ActiveJob::Continuable

  def perform(user_id)
    step :export_data  { export_json_files }
    step :export_files { |step| copy_attachments(step) }
    step :build_zip    { build_archive }
    step :notify       { notify_user(user_id) }
  end
end
```

---

## config/ci.rb — Local CI DSL

```ruby
CI.run do
  step "Setup",    "bin/setup --skip-server"
  step "Rubocop",  "bin/rubocop"
  step "Brakeman", "bin/brakeman --quiet"
  step "Tests",    "bin/rails test"
  step "System",   "bin/rails test:system"
end
```

Run with `bin/ci`. No external CI service needed for contributors.

---

## format.md — Markdown endpoint for essays

```ruby
# app/controllers/public/essays_controller.rb
def show
  @essay = Essay.published.find_by!(slug: params[:slug])
  respond_to do |format|
    format.html
    format.md { render plain: @essay.content.to_markdown }
  end
end
```

Route: `GET /essays/:slug.md` — useful for RSS readers, CLI tools, AI agents.

---

## Rails.event.notify — Self-hosted analytics

```ruby
# In every public controller action
Rails.event.notify("essay.viewed", essay_id: @essay.id, slug: @essay.slug)
Rails.event.notify("project.viewed", project_id: @project.id)
Rails.event.notify("page.viewed", path: request.path)
```

```ruby
# config/initializers/analytics.rb
Rails.event.subscribe("essay.viewed") do |event|
  PageView.create!(event: event.name, payload: event.payload)
end
```

Schema: `page_views: id, event(string), payload(json), created_at`

---

## rate_limit — Built-in throttling (Rails 8.0)

```ruby
# app/controllers/public/essays_controller.rb
rate_limit to: 60, within: 1.minute, only: :index
```

Apply to: `/essays` index, RSS feed, `/essays/:slug.md`.
No Rack::Attack gem needed.

---

## fresh_when — HTTP caching

```ruby
# Every public#show
def show
  @essay = Essay.published.find_by!(slug: params[:slug])
  fresh_when @essay  # ETag + Last-Modified → 304 if unchanged
end

# Every public#index
def index
  @essays = Essay.published.order(published_at: :desc)
  fresh_when @essays
end
```

---

## YJIT

```ruby
# config/environments/production.rb
config.yjit = true  # ~15-20% performance boost
```
