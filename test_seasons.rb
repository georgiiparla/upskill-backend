require './config/environment' if File.exist?('./config/environment.rb')
require './app/controllers/application_controller'

app = ApplicationController.new
app.helpers.run_leaderboard_reset_job(force: true)
puts "Leaderboard reset job ran!"
