class AddDurationToLeaderboardSeasons < ActiveRecord::Migration[7.2]
  def change
    add_column :leaderboard_seasons, :start_date, :datetime
    add_column :leaderboard_seasons, :end_date, :datetime
  end
end
