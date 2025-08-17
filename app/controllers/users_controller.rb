require 'sinatra/base'

class UsersController < Sinatra::Base
  # GET /users
  get '/' do
    'This is the list of all users'
  end

  # GET /users/123
  get '/:id' do
    "This is the profile for user #{params['id']}"
  end
  
  # POST /users
  post '/' do
    'Create a new user'
  end
end