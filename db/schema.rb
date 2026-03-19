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

ActiveRecord::Schema[8.0].define(version: 2026_03_19_111538) do
  create_table "badges", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_key"
  end

  create_table "habit_logs", force: :cascade do |t|
    t.date "date"
    t.boolean "completed"
    t.integer "habit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_habit_logs_on_habit_id"
  end

  create_table "habits", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "frequency", default: "daily", null: false
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "title"
    t.integer "habit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_tags_on_habit_id"
  end

  create_table "user_badges", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.integer "total_xp"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "last_daily_login"
    t.integer "login_streak"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "habit_logs", "habits"
  add_foreign_key "habits", "users"
  add_foreign_key "tags", "habits"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
end
