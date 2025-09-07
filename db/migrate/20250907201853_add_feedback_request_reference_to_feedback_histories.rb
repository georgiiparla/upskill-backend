class AddFeedbackRequestReferenceToFeedbackHistories < ActiveRecord::Migration[7.2]
  def change
    add_reference :feedback_histories, :feedback_request, foreign_key: true, null: true
  end
end