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

ActiveRecord::Schema[7.2].define(version: 2025_09_16_133316) do
  create_table "activity_streams", force: :cascade do |t|
    t.integer "actor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.index ["actor_id"], name: "index_activity_streams_on_actor_id"
    t.index ["target_type", "target_id"], name: "index_activity_streams_on_target"
  end

  create_table "agenda_items", force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.string "category"
    t.date "due_date"
    t.string "icon_name", default: "ClipboardList", null: false
    t.integer "editor_id"
    t.string "link"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["editor_id"], name: "index_agenda_items_on_editor_id"
  end

  create_table "feedback_requests", force: :cascade do |t|
    t.integer "requester_id", null: false
    t.string "topic", null: false
    t.text "details"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag"
    t.datetime "expires_at"
    t.string "visibility", default: "public", null: false
    t.index ["requester_id"], name: "index_feedback_requests_on_requester_id"
    t.index ["status"], name: "index_feedback_requests_on_status"
    t.index ["tag"], name: "index_feedback_requests_on_tag", unique: true
  end

  create_table "feedback_submission_likes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "feedback_submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_submission_id"], name: "index_feedback_submission_likes_on_feedback_submission_id"
    t.index ["user_id", "feedback_submission_id"], name: "idx_on_user_id_feedback_submission_id_d5f433d3e0", unique: true
    t.index ["user_id"], name: "index_feedback_submission_likes_on_user_id"
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
  end

  add_foreign_key "activity_streams", "users", column: "actor_id"
  add_foreign_key "agenda_items", "users", column: "editor_id"
  add_foreign_key "feedback_requests", "users", column: "requester_id"
  add_foreign_key "feedback_submission_likes", "feedback_submissions"
  add_foreign_key "feedback_submission_likes", "users"
  add_foreign_key "feedback_submissions", "feedback_requests"
  add_foreign_key "feedback_submissions", "users"
  add_foreign_key "leaderboards", "users"
end
