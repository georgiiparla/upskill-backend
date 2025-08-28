require 'sinatra/json'
require_relative './application_controller'

class LeaderboardController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    sql = <<-SQL
      SELECT 
        u.id,
        u.username AS name, 
        l.points, 
        l.badges 
      FROM leaderboard l
      JOIN users u ON l.user_id = u.id
      ORDER BY l.points DESC
    SQL
    result = DB.execute(sql)
    
    leaderboard = result.map do |row|
      row['badges'] = row['badges'] ? row['badges'].split(',') : []
      row
    end
    json leaderboard
  end
end