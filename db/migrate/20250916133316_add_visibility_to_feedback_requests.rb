class AddVisibilityToFeedbackRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :feedback_requests, :visibility, :string, null: false, default: 'public'
  end
end