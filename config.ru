require 'rack/cors'
require_relative './db/connection'

# Require all controllers
require_relative './app/controllers/application_controller'
require_relative './app/controllers/auth_controller'
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

use Rack::Cors do
  allow do
    # This is configured to allow requests from your frontend and Postman.
    # The `credentials: true` part is crucial for session cookies to work.
    origins 'http://localhost:3000' 
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

# Enable and configure cookie-based sessions for all controllers
use Rack::Session::Cookie, {
  key: 'rack.session',
  path: '/',
  expire_after: 2592000, # 30 days in seconds
  # This secret should be kept private in a real application
  secret: '9a78e4f5a3e8c9a3b2b1d0e8c7f9a2b5e4f3a2b1d0c9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1'
}

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/quests') { run QuestsController }
  map('/feedback') { run FeedbackController }
  map('/leaderboard') { run LeaderboardController }
  map('/dashboard') { run DashboardController }
}