require_relative '../spec_helper'

RSpec.describe "Quests API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /quests' do
    it 'returns a list of quests' do
      get '/quests'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to be > 0
    end

    it 'converts the "completed" field to a boolean' do
      get '/quests'
      json_response = JSON.parse(last_response.body)
      
      completed_quest = json_response.find { |q| q['title'] == 'Adaptability Ace' }
      incomplete_quest = json_response.find { |q| q['title'] == 'Leadership Leap' }
      
      expect(completed_quest['completed']).to be true
      expect(incomplete_quest['completed']).to be false
    end
  end
end