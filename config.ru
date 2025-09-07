require 'rack/cors'
require_relative './app/controllers/application_controller'

Dir["./app/controllers/*.rb"].each { |file| require file }

use Rack::Cors do
  allow do
    origins ENV['FRONTEND_URL'] || 'http://localhost:3000'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/dashboard') { run DashboardController }
  map('/feedback_submissions') { run FeedbackController } 
  map('/feedback_prompts') { run FeedbackPromptsController }
  map('/quests') { run QuestsController }
  map('/leaderboard') { run LeaderboardController }
}
