class AuthController < ApplicationController
  post '/signup' do
    user = User.new(
      username: @request_payload['username'],
      email: @request_payload['email'],
      password: @request_payload['password']
    )
    if user.save
      status 201
      json({ message: 'User created successfully' })
    else
      halt 409, json({ error: 'User with this email already exists' })
    end
  end

  post '/login' do
    user = User.find_by(email: @request_payload['email'])
    if user&.authenticate(@request_payload['password'])
      session[:user_id] = user.id
      json({ message: 'Logged in successfully', user: { id: user.id, username: user.username, email: user.email } })
    else
      halt 401, json({ error: 'Invalid email or password' })
    end
  end

  post '/logout' do
    session.clear
    json({ message: 'Logged out successfully' })
  end

  get '/profile' do
    if current_user
      json({ logged_in: true, user: current_user.slice(:id, :username, :email) })
    else
      json({ logged_in: false })
    end
  end
end