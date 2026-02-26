class CreateLeaderboardSeasons < ActiveRecord::Migration[7.2]
  def change
    create_table :leaderboard_seasons do |t|
      t.integer :season_number, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :points, default: 0, null: false
      t.integer :public_points, default: 0, null: false
      t.text :badges

      t.timestamps
    end

    add_index :leaderboard_seasons, [:season_number, :user_id], unique: true
    add_index :leaderboard_seasons, :season_number
  end
end
