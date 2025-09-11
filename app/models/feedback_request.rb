class FeedbackRequest < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  has_many :feedback_submissions

  validates :topic, presence: true
  validates :tag, presence: true, uniqueness: true

  before_create :set_expiration_date

  private

  def set_expiration_date
    self.expires_at = Time.now + AppConfig::FEEDBACK_REQUEST_LIFESPAN.seconds
  end
end