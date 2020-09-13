# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_07_091810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "active", default: true
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "callback_sessions", force: :cascade do |t|
    t.boolean "active"
    t.json "results"
    t.json "params"
    t.string "ip"
    t.string "uuid"
    t.string "referrer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_callback_sessions_on_uuid"
  end

  create_table "identities", force: :cascade do |t|
    t.string "platform"
    t.string "identifier"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform", "identifier"], name: "index_identities_on_platform_and_identifier", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "ranks", force: :cascade do |t|
    t.string "name"
    t.string "realm"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["realm", "user_id"], name: "index_ranks_on_realm_and_user_id", unique: true
    t.index ["user_id"], name: "index_ranks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "identities", "users"
  add_foreign_key "ranks", "users"
end
