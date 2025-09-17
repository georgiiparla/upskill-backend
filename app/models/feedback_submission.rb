class FeedbackSubmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_request, optional: true
  has_many :feedback_submission_likes, dependent: :destroy

  validates :content, presence: true, length: { minimum: 10 }

  SENTIMENT_MAP = {
    1 => 'Below Expectations',
    2 => 'Meets Expectations',
    3 => 'Exceeds Expectations',
    4 => 'Far Exceeds Expectations'
  }.freeze

  def sentiment_text
    SENTIMENT_MAP[sentiment]
  end

  def as_json(options = {})
    super(options).merge(
      'sentiment_text' => sentiment_text
    )
  end
end
