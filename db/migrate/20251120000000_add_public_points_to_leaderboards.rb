class AddPublicPointsToLeaderboards < ActiveRecord::Migration[7.2]
  def change
    # Add the shadow column used for the public leaderboard
    add_column :leaderboards, :public_points, :integer, default: 0, null: false

    # Initialize public_points with the current real-time points
    # This ensures the leaderboard works immediately upon deployment
    up_only do
      execute 'UPDATE leaderboards SET public_points = points'
    end
  end
end