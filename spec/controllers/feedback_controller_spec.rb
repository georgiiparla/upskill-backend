require_relative '../spec_helper'

RSpec.describe "Feedback API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /feedback' do
    it 'returns the first page of feedback for the current user' do
      get '/feedback', { page: 1, limit: 2 }
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response['items']).to be_an(Array)
      expect(json_response['items'].first['user_id']).to eq(1)
    end

    it 'correctly reports hasMore when there are more pages' do
      DB.execute("INSERT INTO feedback_history (user_id, subject, content) VALUES (?, ?, ?)", 1, 'Test Subject 2', 'Test Content 2')
      
      get '/feedback', { page: 1, limit: 1 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be true
    end

    it 'correctly reports !hasMore on the last page' do
      get '/feedback', { page: 2, limit: 2 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be false
    end
  end
end