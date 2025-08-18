require 'rack/cors'

# ... (keep existing requires)
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'

# ... (keep CORS block unchanged)
use Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

run Rack::Builder.new {
  # ... (keep existing maps)
  map '/quests' do
    run QuestsController
  end
  
  # Add this block for the new feedback route
  map '/feedback' do
    run FeedbackController
  end

  map '/leaderboard' do
    run LeaderboardController
  end
}