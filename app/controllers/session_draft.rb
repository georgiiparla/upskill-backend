require 'sinatra/base'

class MainApp < Sinatra::Base
  enable :sessions
  set :session_secret, '9a78e4f5a3e8c9a3b2b1d0e8c7f9a2b5e4f3a2b1d0c9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1'

  get '/' do
    'Hello world! This is the main application.'
  end
  
  get '/about' do
    'This is the about page.'
  end

  get '/remember' do
    session[:message] = "I'm remembering this!"
    'Saved a message to your session.'
  end

  get '/recall' do
    if session[:message]
      "The message from your session is: #{session[:message]}"
    else
      "There is no message in your session."
    end
  end
  
  get '/forget' do
    session.clear
    'Session cleared.'
  end
end