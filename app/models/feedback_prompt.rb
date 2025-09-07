class FeedbackPrompt < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  has_many :feedback_submissions
end