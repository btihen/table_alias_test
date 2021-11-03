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

ActiveRecord::Schema.define(version: 2021_10_30_211552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "town"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lease_subletters", force: :cascade do |t|
    t.bigint "lease_id", null: false
    t.bigint "subletter_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lease_id"], name: "index_lease_subletters_on_lease_id"
    t.index ["subletter_id"], name: "index_lease_subletters_on_subletter_id"
  end

  create_table "leases", force: :cascade do |t|
    t.bigint "objekt_id", null: false
    t.bigint "prior_lease_id"
    t.bigint "renter_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["objekt_id"], name: "index_leases_on_objekt_id"
    t.index ["prior_lease_id"], name: "index_leases_on_prior_lease_id"
    t.index ["renter_id"], name: "index_leases_on_renter_id"
  end

  create_table "objekts", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_objekts_on_address_id"
    t.index ["owner_id"], name: "index_objekts_on_owner_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.bigint "address_id", null: false
    t.bigint "language_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_people_on_address_id"
    t.index ["language_id"], name: "index_people_on_language_id"
  end

  add_foreign_key "lease_subletters", "leases"
  add_foreign_key "lease_subletters", "people", column: "subletter_id"
  add_foreign_key "leases", "leases", column: "prior_lease_id"
  add_foreign_key "leases", "objekts"
  add_foreign_key "leases", "people", column: "renter_id"
  add_foreign_key "objekts", "addresses"
  add_foreign_key "objekts", "people", column: "owner_id"
  add_foreign_key "people", "addresses"
  add_foreign_key "people", "languages"
end
