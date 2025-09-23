require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :activity_streams, foreign_key: 'actor_id', dependent: :destroy
  has_many :feedback_submissions, dependent: :destroy
  has_many :feedback_requests, foreign_key: 'requester_id', dependent: :destroy
  has_many :feedback_submission_likes, dependent: :destroy
  has_one :leaderboard, dependent: :destroy

  has_many :email_aliases, class_name: 'UserEmailAlias', dependent: :destroy

  def self.is_creation_authorized?(email)
    return false unless email.is_a?(String)

    normalized_email = email.downcase.strip

    allowed_domain = ENV['ALLOWED_DOMAIN']
    is_domain_allowed = allowed_domain && normalized_email.end_with?("@#{allowed_domain}")

    whitelisted_emails_str = ENV['WHITELISTED_EMAILS'] || ''
    whitelisted_emails = whitelisted_emails_str.split(',').map(&:strip).map(&:downcase)
    is_email_whitelisted = whitelisted_emails.include?(normalized_email)

    is_domain_allowed || is_email_whitelisted
  end
end