require 'rack/cors'
require_relative './app/controllers/application_controller'

# Load all individual controllers
Dir["./app/controllers/*.rb"].each { |file| require file }

# --- Middleware Setup ---
# This is the correct place to configure middleware for the whole app.

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

# Session Middleware with production-safe settings
use Rack::Session::Cookie, {
  key: 'rack.session',
  path: '/',
  expire_after: 2592000,
  secret: ENV['SESSION_SECRET'] || 'dfb4d95774044fb093def2b7f4788322b4d7cf9970ccbd0d3e516bb31fefa7e7a932fcd88e0da4d0a6dc5c02ccf2f5a26cc59d3899bd9492fd37ce4c1fe75393',
  same_site: ENV['RACK_ENV'] == 'production' ? :none : :lax,
  secure: ENV['RACK_ENV'] == 'production'
}

# --- Route Mapping ---
# This block tells the server which controller to use for each URL prefix.
run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/dashboard') { run DashboardController }
  map('/feedback') { run FeedbackController }
  map('/quests') { run QuestsController }
  map('/leaderboard') { run LeaderboardController }
}