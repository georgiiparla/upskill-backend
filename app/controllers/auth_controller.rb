require 'sinatra/json'
require 'bcrypt'
require_relative './application_controller'

class AuthController < ApplicationController
  # SIGN UP a new user
  # POST /auth/signup
  post '/signup' do
    username = @request_payload['username']
    email = @request_payload['email']
    password = @request_payload['password']

    if username.nil? || email.nil? || password.nil?
      halt 400, json({ error: 'Username, email, and password are required' })
    end

    # Check if a user with that email already exists
    existing_user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)
    if existing_user
      halt 409, json({ error: 'User with this email already exists' })
    end

    # Hash the password for secure storage
    password_digest = BCrypt::Password.create(password)

    DB.execute(
      "INSERT INTO users (username, email, password_digest) VALUES (?, ?, ?)",
      username,
      email,
      password_digest
    )

    status 201
    json({ message: 'User created successfully' })
  end

  # LOGIN an existing user
  # POST /auth/login
  post '/login' do
    email = @request_payload['email']
    password = @request_payload['password']

    if email.nil? || password.nil?
      halt 400, json({ error: 'Email and password are required' })
    end

    user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)

    # Verify user exists and password is correct
    if user && BCrypt::Password.new(user['password_digest']) == password
      session[:user_id] = user['id'] # Create the session
      json({ message: 'Logged in successfully', user: { id: user['id'], username: user['username'], email: user['email'] } })
    else
      halt 401, json({ error: 'Invalid email or password' })
    end
  end

  # LOGOUT the current user
  # POST /auth/logout
  post '/logout' do
    session.clear
    json({ message: 'Logged out successfully' })
  end

  # Check the current user's session status
  # GET /auth/profile
  get '/profile' do
    if logged_in?
      json({ logged_in: true, user: current_user })
    else
      json({ logged_in: false })
    end
  end
end