class AddLastViewedActivityStreamToUsers < ActiveRecord::Migration[7.2]
  def change
    # 1. Add the column, allowing NULL temporarily
    add_column :users, :last_viewed_activity_stream, :datetime

    # 2. Update existing records with current time
    User.update_all(last_viewed_activity_stream: Time.current)

    # 3. Change the column to NOT NULL
    change_column_null :users, :last_viewed_activity_stream, false

    # 4. Set the dynamic default for new records using database function
    change_column_default :users, :last_viewed_activity_stream, from: nil, to: -> { "CURRENT_TIMESTAMP" }
  end
end
