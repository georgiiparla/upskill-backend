require './config/environment' if File.exist?('./config/environment.rb')
require './app/controllers/application_controller'
Dir["./app/controllers/*.rb"].each { |file| require file }

app = Rack::Builder.new {
  map('/admin') { run AdminController }
}.to_app

request = Rack::MockRequest.new(app)
# admin_protected! bypass might be required, let's see if we get 401
# Actually admin_protected! expects a valid user session. Mocking current_user might be hard.
# Let's just run curl on the live server, we have rackup running.
# Wait, curl requires a session cookie or header. 
