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

ActiveRecord::Schema[7.2].define(version: 2026_02_14_124411) do
  create_table "estimation_items", force: :cascade do |t|
    t.integer "value"
    t.string "title"
    t.integer "estimation_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "fixed", default: false, null: false
    t.integer "quantity", default: 1, null: false
    t.float "actual_value"
    t.float "order", default: 0.0, null: false
    t.index ["estimation_id", "order"], name: "index_estimation_items_on_estimation_id_and_order"
    t.index ["estimation_id"], name: "index_estimation_items_on_estimation_id"
  end

  create_table "estimation_shares", force: :cascade do |t|
    t.integer "estimation_id", null: false
    t.integer "shared_with_user_id"
    t.string "shared_with_email"
    t.datetime "last_accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estimation_id", "shared_with_email"], name: "index_estimation_shares_on_estimation_and_email", unique: true
    t.index ["estimation_id", "shared_with_user_id"], name: "index_estimation_shares_on_estimation_and_user", unique: true
    t.index ["estimation_id"], name: "index_estimation_shares_on_estimation_id"
    t.index ["shared_with_email"], name: "index_estimation_shares_on_shared_with_email"
    t.index ["shared_with_user_id"], name: "index_estimation_shares_on_shared_with_user_id"
  end

  create_table "estimations", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "tracking_mode", default: false, null: false
    t.string "share_token"
    t.index ["share_token"], name: "index_estimations_on_share_token", unique: true
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
    t.datetime "banned_at"
    t.string "banned_by_email"
    t.index ["banned_at"], name: "index_users_on_banned_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "estimation_items", "estimations"
  add_foreign_key "estimation_shares", "estimations"
  add_foreign_key "estimation_shares", "users", column: "shared_with_user_id"
  add_foreign_key "estimations", "users"
end
