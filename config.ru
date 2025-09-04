require 'rack/cors'
require_relative './app/controllers/application_controller'

# Load all individual controllers
Dir["./app/controllers/*.rb"].each { |file| require file }

# CORS Middleware for frontend communication
use Rack::Cors do
  allow do
    origins ENV['FRONTEND_URL'] || 'http://localhost:3000'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

# --- Route Mapping ---
# This block tells the server which controller to use for each URL prefix.
run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/dashboard') { run DashboardController }
  map('/feedback') { run FeedbackController }
  map('/quests') { run QuestsController }
  map('/leaderboard') { run LeaderboardController }
}