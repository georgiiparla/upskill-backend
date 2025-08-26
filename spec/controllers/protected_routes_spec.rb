# This file tests all controllers that have the `protected!` before filter.

require_relative '../spec_helper'

PROTECTED_ROUTES = {
  'Dashboard'   => '/dashboard',
  'Feedback'    => '/feedback',
  'Leaderboard' => '/leaderboard',
  'Quests'      => '/quests'
}.freeze

PROTECTED_ROUTES.each do |name, path|
  RSpec.describe "#{name} API (Protected)", type: :request do
    describe "GET #{path}" do
      context "when user is not authenticated" do
        it "returns a 401 Unauthorized error" do
          get path
          expect(last_response.status).to eq(401)
          json_response = JSON.parse(last_response.body)
          expect(json_response['error']).to eq('Unauthorized')
        end
      end

      context "when user is authenticated" do
        it "returns a 200 OK status" do
          post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
          get path
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end