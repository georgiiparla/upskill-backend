class FeedbackRequest < ActiveRecord::Base
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :pair, class_name: 'User', foreign_key: 'pair_id', optional: true
  has_many :feedback_submissions, dependent: :destroy

  has_many :activity_streams, as: :target, dependent: :destroy

  validates :topic, presence: true
  validates :tag, presence: true, uniqueness: true

  validates :visibility, inclusion: { in: %w(public requester_only), message: "%{value} is not a valid visibility setting" }

  before_create :set_expiration_date

  private

  def set_expiration_date
    self.expires_at = Time.now + AppConfig::FEEDBACK_REQUEST_LIFESPAN.seconds
  end
end