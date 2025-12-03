class AddTimestampsToLeaderboards < ActiveRecord::Migration[7.2]
  def change
    # Add created_at and updated_at columns
    # We set a default of Time.now so existing rows don't crash with NULL values
    add_timestamps :leaderboards, default: Time.now, null: false
  end
end