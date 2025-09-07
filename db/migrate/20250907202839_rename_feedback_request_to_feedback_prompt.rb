class RenameFeedbackRequestToFeedbackPrompt < ActiveRecord::Migration[7.2]
  def change
    rename_table :feedback_requests, :feedback_prompts
  end
end