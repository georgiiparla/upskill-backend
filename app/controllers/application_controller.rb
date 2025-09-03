# app/controllers/application_controller.rb
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'bcrypt'

# Load all models
Dir["./app/models/*.rb"].each { |file| require file }

class ApplicationController < Sinatra::Base
  set :database_file, '../../config/database.yml'
  
  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
    def protected!
      halt 401, json({ error: 'Unauthorized' }) unless current_user
    end
  end

  # JSON Body Parser
  before do
    @request_payload = {}
    body = request.body.read
    if !body.empty? && request.content_type&.include?("application/json")
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end
end