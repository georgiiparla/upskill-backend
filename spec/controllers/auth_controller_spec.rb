# spec/controllers/auth_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Authentication API", type: :request do
  let(:valid_signup_params) { { username: 'New User', email: 'new@example.com', password: 'password123' } }
  let(:valid_login_params) { { email: 'test@example.com', password: 'password123' } }

  # FIX: This block runs before each test in this file to ensure a clean state
  # for the user being created or deleted.
  before(:each) do
    DB.execute("DELETE FROM users WHERE email = ?", 'new@example.com')
  end

  describe 'POST /auth/signup' do
    context 'with valid parameters' do
      it 'creates a new user and returns a success message' do
        post '/auth/signup', valid_signup_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(201)
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('User created successfully')
      end
    end

    context 'with a duplicate email' do
      it 'returns a 409 conflict error' do
        # First, create the user that we expect to conflict with
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        
        # Now, try to create it again
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(409)
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to eq('User with this email already exists')
      end
    end
  end

  describe 'POST /auth/login' do
    context 'with valid credentials' do
      it 'logs the user in and creates a session' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Set-Cookie']).to include('rack.session')
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('Logged in successfully')
      end
    end
  end

  describe 'GET /auth/profile' do
    context 'when user is logged in' do
      it 'returns the current user information' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be true
        expect(json_response['user']['id']).to eq(1)
      end
    end

    context 'when user is not logged in' do
      it 'returns a logged_in: false status' do
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be false
      end
    end
  end

  describe 'POST /auth/logout' do
    it 'clears the session and logs the user out' do
      # First, log in to establish a session
      post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
      
      # Then, log out
      post '/auth/logout'
      expect(last_response.status).to eq(200)
      
      # FIX: Instead of checking the cookie, verify the *effect* of logging out.
      # A subsequent request to a protected endpoint should fail.
      get '/auth/profile'
      json_response = JSON.parse(last_response.body)
      expect(json_response['logged_in']).to be false
    end
  end
end