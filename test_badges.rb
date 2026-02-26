require './config/environment' if File.exist?('./config/environment.rb')
require './app/controllers/application_controller'
Dir["./app/controllers/*.rb"].each { |file| require file }

app = Rack::Builder.new {
  map('/leaderboard') { run LeaderboardController }
}.to_app

request = Rack::MockRequest.new(app)
response = request.get('/leaderboard')
puts "HTTP #{response.status}"
puts "Removed Badges Successfully!" unless response.body.include?("badges")
