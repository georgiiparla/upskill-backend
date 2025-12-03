class LeaderboardController < ApplicationController
  get '/' do
  # 1. Fetch the raw leaderboard entries
      entries = Leaderboard.includes(:user)
             .order(public_points: :desc)
             .map do |entry|
        { 
          id: entry.id,
          user_id: entry.user_id, # FIX: Added user_id to identify "Me" on frontend
          name: entry.user.username,
          points: entry.public_points,
          # rank is calculated on the frontend now
        }
      end

    # 2. Find the last sync time (Max updated_at serves as the merge time)
    # If nil (no data), fallback to now.
    last_sync = Leaderboard.maximum(:updated_at) || Time.now

    # 3. Return the WRAPPED object
    json({
      users: entries,
      last_updated_at: last_sync
    })
  end

  get '/me' do
    protected!

    # Current user sees their LIVE points (immediate feedback) to preserve Gamification loop.
    entry = current_user.leaderboard || current_user.create_leaderboard(points: 0, badges: nil)
    
    # Calculate rank based on PUBLIC points so it matches the leaderboard view.
    # This prevents confusion ("Why am I #1 here but #5 on the list?").
    all_entries = Leaderboard.order(public_points: :desc, user_id: :asc).pluck(:user_id)
    rank = all_entries.index(current_user.id)&.+(1)

    json({
      id: current_user.id,
      name: current_user.username,
      points: entry.points.to_i, # Show live points here for personal satisfaction
      badges: (entry.badges ? entry.badges.split(',') : []),
      rank: rank || all_entries.size + 1
    })
  end
end