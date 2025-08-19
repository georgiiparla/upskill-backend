# app/controllers/application_controller.rb

require 'sinatra/base'
require 'sinatra/json'

class ApplicationController < Sinatra::Base
  # --- Global 500 Error Handler ---
  error do
    puts "ERROR: #{env['sinatra.error'].message}"
    puts env['sinatra.error'].backtrace.join("\n")
    status 500
    json({ error: 'An internal server error occurred.' })
  end

  # --- Specific Handler for Database Busy Errors ---
  error SQLite3::BusyException do
    status 503 # Service Unavailable
    json({ error: 'The database is currently busy. Please try again in a moment.' })
  end

  # --- Global 404 Not Found Handler ---
  not_found do
    status 404
    json({ error: 'Not Found' })
  end

  helpers do
    def current_user
      return @current_user if @current_user
      return nil unless session[:user_id]
      @current_user = DB.get_first_row("SELECT id, username, email FROM users WHERE id = ?", session[:user_id])
    end

    def logged_in?
      !current_user.nil?
    end

    def protected!
      halt 401, json({ error: 'Unauthorized' }) unless logged_in?
    end
  end

  # --- JSON Body Parser ---
  before do
    @request_payload = {}
    
    # FINAL FIX: The most robust method. Read the body. If the resulting
    # string is empty, do nothing. Otherwise, parse it. This works
    # in both test and live environments without causing errors.
    body = request.body.read
    
    unless body.empty?
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end
end
