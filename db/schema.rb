ActiveRecord::Schema[7.0].define(version: 2025_09_03_200000) do
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

  create_table "feedback_histories", force: :cascade do |t|
    t.integer "user_id"
    t.string "subject"
    t.text "content"
    t.string "sentiment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_feedback_histories_on_user_id"
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
  add_foreign_key "feedback_histories", "users"
  add_foreign_key "leaderboards", "users"
end