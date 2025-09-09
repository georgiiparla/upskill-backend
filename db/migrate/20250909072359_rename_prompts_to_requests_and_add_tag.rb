class RenamePromptsToRequestsAndAddTag < ActiveRecord::Migration[7.2]
  def change
    rename_table :feedback_prompts, :feedback_requests if table_exists?(:feedback_prompts)

    if column_exists?(:feedback_submissions, :feedback_prompt_id)
      rename_column :feedback_submissions, :feedback_prompt_id, :feedback_request_id
    end

    unless column_exists?(:feedback_requests, :tag)
      add_column :feedback_requests, :tag, :string
      add_index :feedback_requests, :tag, unique: true
    end
  end
end