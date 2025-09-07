class RenameFeedbackHistoryToFeedbackSubmission < ActiveRecord::Migration[7.2]
  def change
    rename_table :feedback_histories, :feedback_submissions

    # Rename the foreign key column to match the new table name
    rename_column :feedback_submissions, :feedback_request_id, :feedback_prompt_id
  end
end