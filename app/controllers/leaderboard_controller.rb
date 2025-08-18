## File: app/controllers/leaderboard_controller.rb

require 'sinatra/base'
require 'sinatra/json'

class LeaderboardController < Sinatra::Base
  get '/' do
    result = DB.execute("SELECT * FROM leaderboard ORDER BY points DESC")
    leaderboard = result.map do |row|
      row['badges'] = row['badges'] ? row['badges'].split(',') : []
      row
    end
    json leaderboard
  end
end