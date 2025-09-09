class FeedbackRequest < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  has_many :feedback_submissions

  validates :topic, presence: true
  validates :tag, presence: true, uniqueness: true
end