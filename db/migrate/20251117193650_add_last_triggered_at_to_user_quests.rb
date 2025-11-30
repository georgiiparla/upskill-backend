class AddLastTriggeredAtToUserQuests < ActiveRecord::Migration[7.0]
  def change
    add_column :user_quests, :last_triggered_at, :datetime
  end
end
