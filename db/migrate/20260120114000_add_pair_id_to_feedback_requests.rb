class AddPairIdToFeedbackRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :feedback_requests, :pair_id, :integer
    add_index :feedback_requests, :pair_id
  end
end
