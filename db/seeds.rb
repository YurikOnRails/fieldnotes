# Admin user — idempotent, safe to re-run
email    = ENV.fetch("ADMIN_EMAIL",    "admin@example.com")
password = ENV.fetch("ADMIN_PASSWORD", "changeme123!")

user = User.find_or_initialize_by(email_address: email)
user.password = password if user.new_record?
user.save!

puts "Admin user ready: #{user.email_address}"
