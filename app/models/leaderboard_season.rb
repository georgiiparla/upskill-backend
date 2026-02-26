class LeaderboardSeason < ActiveRecord::Base
  belongs_to :user

  validates :season_number, presence: true
  validates :user_id, uniqueness: { scope: :season_number }
end
