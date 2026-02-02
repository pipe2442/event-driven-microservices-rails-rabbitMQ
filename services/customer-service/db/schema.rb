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

ActiveRecord::Schema[8.1].define(version: 2026_02_02_003658) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "customers", force: :cascade do |t|
    t.text "address", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "orders_count", default: 0, null: false
    t.uuid "public_id", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_customers_on_name"
    t.index ["public_id"], name: "index_customers_on_public_id", unique: true
  end

  create_table "processed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_id", null: false
    t.string "event_name", null: false
    t.datetime "occurred_at"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_processed_events_on_event_id", unique: true
  end
end
