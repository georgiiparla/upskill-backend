# app/controllers/application_controller.rb
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'bcrypt'
require 'logger'

# Load all models
Dir["./app/models/*.rb"].each { |file| require file }

class ApplicationController < Sinatra::Base
  set :database_file, '../../config/database.yml'

  configure do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    set :logger, logger
    use Rack::CommonLogger, logger
  end
  
  helpers do
    def current_user
      # --- NEW LOGS ---
      settings.logger.info "Checking for current user. Session ID from cookie: #{session[:user_id]}"
      @current_user ||= User.find_by(id: session[:user_id])
      settings.logger.info "User found: #{@current_user.nil? ? 'No' : "Yes, ID: #{@current_user.id}"}"
      # --- END LOGS ---
      @current_user
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