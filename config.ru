require 'dotenv/load' if ENV['RACK_ENV'] == 'development'

require 'rack/cors'
require_relative './app/controllers/application_controller'

 

use Rack::Cors do
  allow do
    origins ENV['FRONTEND_URL'] || 'http://localhost:3000'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

Dir["./app/controllers/*.rb"].each { |file| require file }

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/dashboard') { run DashboardController }
  map('/feedback_submissions') { run FeedbackSubmissionsController }
  map('/feedback_requests') { run FeedbackRequestsController }
  map('/quests') { run QuestsController }
  map('/leaderboard') { run LeaderboardController }
  map('/admin') { run AdminController }
  map('/agenda_items') { run AgendaItemsController }
  map('/me/aliases') { run UserAliasesController }
  map('/users') { run UsersController }
}