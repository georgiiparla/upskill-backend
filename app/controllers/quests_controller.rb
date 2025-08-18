require 'sinatra/base'
require 'sinatra/json'

class QuestsController < Sinatra::Base
  get '/' do
    result = DB.execute("SELECT * FROM quests ORDER BY id ASC")
    quests = result.map do |row|
      row['completed'] = row['completed'] == 1
      row
    end
    json quests
  end
end