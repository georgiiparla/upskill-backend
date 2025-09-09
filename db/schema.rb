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

ActiveRecord::Schema[7.2].define(version: 2025_09_09_121548) do
  create_table "activity_streams", force: :cascade do |t|
    t.integer "user_id"
    t.text "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_activity_streams_on_user_id"
  end

  create_table "agenda_items", force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.string "category"
    t.date "due_date"
  end

  create_table "feedback_requests", force: :cascade do |t|
    t.integer "requester_id", null: false
    t.string "topic", null: false
    t.text "details"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
    t.index ["requester_id"], name: "index_feedback_requests_on_requester_id"
    t.index ["status"], name: "index_feedback_requests_on_status"
    t.index ["tag"], name: "index_feedback_requests_on_tag", unique: true
  end

  create_table "feedback_submissions", force: :cascade do |t|
    t.integer "user_id"
    t.string "subject"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "feedback_request_id"
    t.integer "sentiment"
    t.index ["feedback_request_id"], name: "index_feedback_submissions_on_feedback_request_id"
    t.index ["user_id"], name: "index_feedback_submissions_on_user_id"
  end

  create_table "leaderboards", force: :cascade do |t|
    t.integer "user_id"
    t.integer "points"
    t.text "badges"
    t.index ["user_id"], name: "index_leaderboards_on_user_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.string "title"
    t.date "meeting_date"
    t.string "status"
  end

  create_table "quests", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "points"
    t.integer "progress"
    t.boolean "completed", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "activity_streams", "users"
  add_foreign_key "feedback_requests", "users", column: "requester_id"
  add_foreign_key "feedback_submissions", "feedback_requests"
  add_foreign_key "feedback_submissions", "users"
  add_foreign_key "leaderboards", "users"
end
