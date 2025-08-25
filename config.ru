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
  expire_after: 2592000,
  secret: ENV['SESSION_SECRET'] || '2b2f2e9de188a71851c52961ad8aef439867e2115429a230c86b618e5d0f135c491914cf1ad21a416407ddc9a0a469e038f91b69fd2c7cf9620261725076689f',
  same_site: :lax,
  secure: false
}

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/quests') { run QuestsController }
  map('/feedback') { run FeedbackController }
  map('/leaderboard') { run LeaderboardController }
  map('/dashboard') { run DashboardController }
}