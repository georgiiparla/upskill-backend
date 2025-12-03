class FeedbackSubmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_request, optional: true

  has_many :feedback_submission_likes, dependent: :destroy
  # Alias for cleaner controller code
  has_many :likes, class_name: 'FeedbackSubmissionLike', dependent: :destroy

  validates :content, presence: true, length: { minimum: 10 }
  
  # SECURITY FIX: Input Validation
  # Ensure sentiment is within valid range to prevent integer overflow or analytics errors
  validates :sentiment, inclusion: { in: 1..4, message: "must be between 1 and 4" }

  SENTIMENT_MAP = {
    1 => 'Below Expectations',
    2 => 'Approaching Expectations',
    3 => 'Meets Expectations',
    4 => 'Exceeds Expectations'
  }.freeze

  def sentiment_text
    SENTIMENT_MAP[sentiment]
  end

  def as_json(options = {})
    # SECURITY FIX: Privacy Leak
    # Explicitly exclude user_id to prevent anonymity bypass via API inspection
    super(options.merge(except: [:user_id])).merge(
      'sentiment_text' => sentiment_text
    )
  end
end