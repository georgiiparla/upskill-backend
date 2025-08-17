#require_relative './config/environment'

require_relative './app/controllers/users_controller'
require_relative './app/controllers/posts_controller'
require_relative './app/controllers/main_app'


run Rack::Builder.new {
  map '/users' do
    run UsersController
  end

  map '/posts' do
    run PostsController
  end
  
  map '/' do
    run MainApp
  end
}