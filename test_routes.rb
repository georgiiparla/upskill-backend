require './config/environment' if File.exist?('./config/environment.rb')
require './app/controllers/application_controller'
Dir["./app/controllers/*.rb"].each { |file| require file }

puts "Routes in LeaderboardController:"
LeaderboardController.routes['GET'].each do |route|
  puts route[0].inspect
end
