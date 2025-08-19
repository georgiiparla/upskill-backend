require 'sinatra/json'
require_relative './application_controller'

class LeaderboardController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    result = DB.execute("SELECT * FROM leaderboard ORDER BY points DESC")
    leaderboard = result.map do |row|
      row['badges'] = row['badges'] ? row['badges'].split(',') : []
      row
    end
    json leaderboard
  end
end