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

ActiveRecord::Schema[7.2].define(version: 2015_07_01_170544) do
  create_table "estimation_items", force: :cascade do |t|
    t.integer "value"
    t.string "title"
    t.integer "estimation_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "fixed", default: false, null: false
    t.integer "quantity", default: 1, null: false
    t.float "actual_value"
    t.index ["estimation_id"], name: "index_estimation_items_on_estimation_id"
  end

  create_table "estimations", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "tracking_mode", default: false, null: false
    t.index ["user_id"], name: "index_estimations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "estimation_items", "estimations"
  add_foreign_key "estimations", "users"
end
