class FeedbackSubmissionLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_submission
end