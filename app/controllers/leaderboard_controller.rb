class LeaderboardController < ApplicationController
  get '/' do
    protected!
    leaderboard_data = Leaderboard.includes(:user).order(points: :desc).map do |entry|
      { id: entry.user.id, name: entry.user.username, points: entry.points, badges: entry.badges ? entry.badges.split(',') : [] }
    end
    json leaderboard_data
  end
end