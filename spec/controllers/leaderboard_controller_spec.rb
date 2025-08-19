# spec/controllers/leaderboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Leaderboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /leaderboard' do
    it 'returns the leaderboard sorted by points descending' do
      get '/leaderboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      points = json_response.map { |entry| entry['points'] }
      expect(points).to eq(points.sort.reverse)
    end

    it 'converts the "badges" field from a string to an array' do
      get '/leaderboard'
      json_response = JSON.parse(last_response.body)
      expect(json_response.first['badges']).to be_an(Array)
    end
  end
end