class FeedbackSubmission < ActiveRecord::Base 
  belongs_to :user
  belongs_to :feedback_request, optional: true
end