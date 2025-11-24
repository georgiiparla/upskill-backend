class AddFirstAwardedAtToUserQuests < ActiveRecord::Migration[7.0]
  def change
    add_column :user_quests, :first_awarded_at, :datetime
  end
end
