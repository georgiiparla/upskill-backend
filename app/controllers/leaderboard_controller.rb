class LeaderboardController < ApplicationController
  get '/' do
    protected!
    leaderboard_data = Leaderboard.includes(:user).order(points: :desc).map do |entry|
      { id: entry.user.id, name: entry.user.username, points: entry.points, badges: entry.badges ? entry.badges.split(',') : [] }
    end
    json leaderboard_data
  end

  get '/me' do
    protected!

    entry = current_user.leaderboard || current_user.create_leaderboard(points: 0, badges: nil)
    all_entries = Leaderboard.order(points: :desc, user_id: :asc).pluck(:user_id)
    rank = all_entries.index(current_user.id)&.+(1)

    json({
      id: current_user.id,
      name: current_user.username,
      points: entry.points.to_i,
      badges: (entry.badges ? entry.badges.split(',') : []),
      rank: rank || all_entries.size + 1
    })
  end
end