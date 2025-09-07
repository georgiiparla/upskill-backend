class FeedbackSubmission < ActiveRecord::Base 
  belongs_to :user
  belongs_to :feedback_prompt, optional: true
end