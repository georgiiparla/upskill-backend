class AddLastCompletedAtToUserQuests < ActiveRecord::Migration[7.0]
  def change
    add_column :user_quests, :last_completed_at, :datetime, null: true
  end
end
