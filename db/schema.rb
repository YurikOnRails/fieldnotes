# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_08_130137) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.text "key_idea"
    t.integer "rating"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "year_read"
  end

  create_table "builds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "finished_on"
    t.string "icon_emoji"
    t.string "kind"
    t.integer "position"
    t.string "slug"
    t.date "started_on"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["slug"], name: "index_builds_on_slug", unique: true
  end

  create_table "essays", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.decimal "latitude"
    t.string "location_name"
    t.decimal "longitude"
    t.datetime "published_at"
    t.string "slug"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_essays_on_slug", unique: true
  end

  create_table "field_items", force: :cascade do |t|
    t.text "caption"
    t.datetime "created_at", null: false
    t.integer "field_series_id", null: false
    t.string "kind"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.string "youtube_url"
    t.index ["field_series_id"], name: "index_field_items_on_field_series_id"
  end

  create_table "field_series", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "kind"
    t.decimal "latitude"
    t.string "location"
    t.decimal "longitude"
    t.string "slug"
    t.date "taken_on"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_field_series_on_slug", unique: true
  end

  create_table "now_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "field_items", "field_series"
  add_foreign_key "sessions", "users"
end
