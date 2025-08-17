require 'sinatra/base'

class PostsController < Sinatra::Base
  get '/' do
    'This is a list of all posts'
  end

  get '/:id' do
    "Viewing post #{params['id']}"
  end
end