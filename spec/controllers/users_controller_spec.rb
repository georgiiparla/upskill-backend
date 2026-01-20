require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  include Rack::Test::Methods

  def app
    # We need to map the new controller in config.ru, but for now we test the controller directly or via app dispatch if mounted.
    # Assuming standard setup where controllers are mapped. 
    # If standard setup uses a rack builder, we might rely on global app definition.
    # For unit testing a specific controller in Sinatra, usually 'app' returns that controller class or a builder.
    # However, based on existing specs, let's see how they do it.
    # Standard usually: class UsersController < ApplicationController; end
    UsersController
  end

  def generate_token(user)
    JWT.encode({ user_id: user.id }, ENV['JWT_SECRET'] || 'test_secret')
  end

  let(:user) { create(:user, username: 'requester') }
  let(:other_user) { create(:user, username: 'target_user') }
  let(:another_user) { create(:user, username: 'random_person') }

  describe 'GET /search' do
    context 'when not authenticated' do
      it 'returns 401' do
        get '/search', q: 'target'
        expect(last_response.status).to eq(401)
      end
    end

    context 'when authenticated' do
      before do
        header 'Authorization', "Bearer #{generate_token(user)}"
      end

      it 'returns a list of users matching the query' do
        # Ensure users exist
        other_user
        another_user
        
        get '/search', q: 'target'
        
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(1)
        expect(json_response.first['username']).to eq('target_user')
      end

      it 'is case insensitive' do
        other_user
        
        get '/search', q: 'TARGET'
        
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body).first['username']).to eq('target_user')
      end

      it 'excludes the current user from results' do
        # Should not find self even if query matches
        get '/search', q: 'requester'
        
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to be_empty
      end

      it 'returns empty list if query is too short' do
        get '/search', q: 'a'
        
        expect(last_response.status).to eq(400) # Or 200 with empty list, let's say 400 for validation
        expect(JSON.parse(last_response.body)['error']).to include('too short')
      end

      it 'rate limits rapid requests' do
        # 1. Success
        get '/search', q: 'test'
        expect(last_response.status).to eq(200)

        # 2. Too fast -> 429
        get '/search', q: 'test'
        expect(last_response.status).to eq(429) unless last_response.status == 200 # Flaky if time flows?
        # Actually RSpec doesn't freeze time by default.
        # But execution is fast (< 0.5s), so it should hit 429.
        if last_response.status == 200
             # Fallback if too slow: force failure or skip
             # But we should expect 429.
        end
        expect(last_response.status).to eq(429)
      end

      it 'allows requests after delay' do
         get '/search', q: 'test'
         expect(last_response.status).to eq(200)

         # Mock Time to simulate delay
         allow(Time).to receive(:now).and_return(Time.now + 1)
         
         get '/search', q: 'test'
         expect(last_response.status).to eq(200)
      end
    end
  end
end
