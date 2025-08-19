# spec/controllers/dashboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Dashboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /dashboard' do
    it 'returns a JSON object with all dashboard components' do
      get '/dashboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response.keys).to contain_exactly(
        'agendaItems', 'activityStream', 'meetings', 'teamEngagement', 'personalEngagement'
      )
    end
  end
end