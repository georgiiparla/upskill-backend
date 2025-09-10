class CreateFeedbackSubmissionLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :feedback_submission_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feedback_submission, null: false, foreign_key: true
      t.timestamps
    end

    add_index :feedback_submission_likes, [:user_id, :feedback_submission_id], unique: true
  end
end
