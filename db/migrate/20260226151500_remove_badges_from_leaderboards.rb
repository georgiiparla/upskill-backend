class RemoveBadgesFromLeaderboards < ActiveRecord::Migration[7.2]
  def change
    remove_column :leaderboards, :badges, :text
    remove_column :leaderboard_seasons, :badges, :text
  end
end
