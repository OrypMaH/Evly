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

ActiveRecord::Schema.define(version: 2026_03_06_055135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approved_event_departments", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "department_id", null: false
    t.bigint "approved_by_user_id", null: false
    t.integer "participants_count", default: 1, null: false
    t.datetime "approved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "directions", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "department_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id", "name"], name: "index_directions_on_department_id_and_name", unique: true
    t.index ["department_id"], name: "index_directions_on_department_id"
  end

  create_table "educational_organizations", force: :cascade do |t|
    t.string "name"
    t.string "federal_district"
    t.string "federal_subject"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_educational_organizations_on_name", unique: true
  end

  create_table "event_levels", force: :cascade do |t|
    t.string "name", null: false
    t.integer "priority", default: 0
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["priority"], name: "index_event_levels_on_priority"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "creator_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "event_level_id"
    t.string "format"
    t.string "location"
    t.bigint "direction_id", null: false
    t.integer "educational_organization_id"
    t.index ["creator_id"], name: "index_events_on_creator_id"
    t.index ["direction_id"], name: "index_events_direction_id"
    t.index ["event_level_id"], name: "index_events_on_event_level_id"
  end

  create_table "offered_event_departments", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "department_id", null: false
    t.bigint "proposed_by_user_id", null: false
    t.datetime "proposed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action", null: false
    t.string "resource", null: false
    t.string "scope", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.index ["name"], name: "index_permissions_on_name", unique: true
  end

  create_table "plan_events", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "event_department_id", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_department_id"], name: "index_plan_events_on_event_department_id"
    t.index ["plan_id"], name: "index_plan_events_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "department_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_plans_on_creator_id"
    t.index ["department_id"], name: "index_plans_on_department_id"
  end

  create_table "responsible_people", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id", "user_id"], name: "idx_responsible_people_on_event_user", unique: true
    t.index ["event_id"], name: "index_responsible_people_on_event_id"
    t.index ["role_id"], name: "index_responsible_people_on_role_id"
    t.index ["user_id"], name: "index_responsible_people_on_user_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "department_id", null: false
    t.index ["department_id"], name: "index_roles_on_department_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "surname", limit: 50
    t.string "name", limit: 50
    t.string "patronymic", limit: 50
    t.string "contact", limit: 50
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "current_role_id"
    t.index ["current_role_id"], name: "index_users_on_current_role_id"
  end

  add_foreign_key "directions", "departments"
  add_foreign_key "events", "directions"
  add_foreign_key "events", "educational_organizations"
  add_foreign_key "events", "event_levels"
  add_foreign_key "events", "users", column: "creator_id"
  add_foreign_key "plan_events", "approved_event_departments", column: "event_department_id"
  add_foreign_key "plan_events", "plans"
  add_foreign_key "plans", "departments"
  add_foreign_key "plans", "users", column: "creator_id"
  add_foreign_key "responsible_people", "events"
  add_foreign_key "responsible_people", "roles"
  add_foreign_key "responsible_people", "users"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "departments"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "roles", column: "current_role_id"
end
