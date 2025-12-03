class AddPointsSnapshotToUserQuests < ActiveRecord::Migration[7.2]
  def change
    # Store the exact points awarded at the time of completion
    # This prevents regression/corruption if Quest points are changed by Admins later
    add_column :user_quests, :points_snapshot, :integer, default: 0, null: false
  end
end