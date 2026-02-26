class LeaderboardController < ApplicationController
  get '/seasons' do
    seasons = LeaderboardSeason.select(:season_number, :start_date, :end_date)
                               .distinct
                               .order(season_number: :desc)
                               .map do |s| 
      {
        season_number: s.season_number,
        start_date: s.start_date,
        end_date: s.end_date
      }
    end
    
    # We want unique objects filtered by season_number, so we uniq them manually if any overlapping dates exist
    json(seasons.uniq { |s| s[:season_number] })
  end

  get '/' do
    season_number = params[:season]&.to_i

    if season_number && season_number > 0
      entries = LeaderboardSeason.where(season_number: season_number).includes(:user)
             .order(public_points: :desc)
             .map do |entry|
        { 
          id: entry.id,
          user_id: entry.user_id,
          name: entry.user.username,
          points: entry.public_points,
        }
      end

      last_sync = LeaderboardSeason.where(season_number: season_number).maximum(:created_at) || Time.now
    else
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
    end

    # 3. Return the WRAPPED object
    json({
      users: entries,
      last_updated_at: last_sync
    })
  end

  get '/me' do
    protected!
    
    season_number = params[:season]&.to_i

    if season_number && season_number > 0
      entry = LeaderboardSeason.find_by(user_id: current_user.id, season_number: season_number)
      
      all_entries = LeaderboardSeason.where(season_number: season_number).order(public_points: :desc, user_id: :asc).pluck(:user_id)
      rank = all_entries.index(current_user.id)&.+(1)

      json({
        id: current_user.id,
        name: current_user.username,
        points: entry ? entry.points : 0,
        rank: rank || all_entries.size + 1
      })
    else
      # Current user sees their LIVE points (immediate feedback) to preserve Gamification loop.
      entry = current_user.leaderboard || current_user.create_leaderboard(points: 0)
      
      # Calculate rank based on PUBLIC points so it matches the leaderboard view.
      # This prevents confusion ("Why am I #1 here but #5 on the list?").
      all_entries = Leaderboard.order(public_points: :desc, user_id: :asc).pluck(:user_id)
      rank = all_entries.index(current_user.id)&.+(1)

      json({
        id: current_user.id,
        name: current_user.username,
        points: entry.points.to_i, # Show live points here for personal satisfaction
        rank: rank || all_entries.size + 1
      })
    end
  end
end