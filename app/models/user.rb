require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password # Handles password hashing via bcrypt
  
  has_many :feedback_histories, dependent: :destroy
  has_many :activity_streams, dependent: :destroy
  has_one :leaderboard, dependent: :destroy
end