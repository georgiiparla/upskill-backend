class AddExpiresAtToFeedbackRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :feedback_requests, :expires_at, :datetime
  end
end