# -----------------------------------------------------------------------------
# File: config.ru (Updated)
# -----------------------------------------------------------------------------
require 'rack/cors'
require_relative './db/connection' # Require the DB connection

# Require all controllers
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

use Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

run Rack::Builder.new {
  map('/quests') { run QuestsController }
  map('/feedback') { run FeedbackController }
  map('/leaderboard') { run LeaderboardController }
  map('/dashboard') { run DashboardController }
}