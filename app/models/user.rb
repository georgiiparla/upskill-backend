require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password # Handles password hashing via bcrypt

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :activity_streams, dependent: :destroy
  has_many :feedback_submissions, dependent: :destroy 
  has_many :feedback_prompts, foreign_key: 'requester_id', dependent: :destroy 
  has_one :leaderboard, dependent: :destroy
end