require 'dotenv/load' if ENV['RACK_ENV'] == 'development'

require 'rack/cors'
require_relative './app/controllers/application_controller'

require 'rack/session/cookie' 

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

use Rack::Session::Cookie, secret: ENV['SESSION_SECRET'] || "7fc10bc317307fa7821062488e86cf461a9ca86ae052e6c72f4b4530bdaea796b02a9d85f54cccdc82d3b19b7eea4dabb3a8d1d031c11db68af2ce70b107da9a"

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
}