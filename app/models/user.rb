require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password # Handles password hashing via bcrypt

  validates :username, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  # Update this line to specify the new foreign key
  has_many :activity_streams, foreign_key: 'actor_id', dependent: :destroy 
  
  has_many :feedback_submissions, dependent: :destroy 
  has_many :feedback_requests, foreign_key: 'requester_id', dependent: :destroy 
  has_one :leaderboard, dependent: :destroy

  has_many :feedback_submission_likes, dependent: :destroy

  def self.is_email_authorized?(email)
    return false unless email.is_a?(String)

    allowed_domain = ENV['ALLOWED_DOMAIN']
    whitelisted_emails_str = ENV['WHITELISTED_EMAILS'] || ''
    whitelisted_emails = whitelisted_emails_str.split(',').map(&:strip)

    is_domain_allowed = allowed_domain && email.end_with?("@#{allowed_domain}")
    is_email_whitelisted = whitelisted_emails.include?(email)

    is_domain_allowed || is_email_whitelisted
  end

  def authorized?
    self.class.is_email_authorized?(self.email)
  end
end