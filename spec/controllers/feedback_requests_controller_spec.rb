require 'spec_helper'

RSpec.describe FeedbackRequestsController do
  def app
    FeedbackRequestsController
  end

  let!(:user) { User.create(username: 'tester', email: 'tester@example.com', password: 'password') }
  let!(:pair_user) { User.create(username: 'pair_buddy', email: 'pair@example.com', password: 'password') }
  let(:token) { JWT.encode({user_id: user.id}, ENV['JWT_SECRET'] || 'test_secret') }
  let(:headers) { { 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' } }

  describe "GET /" do
    context "when a user is a pair on a request" do
      before do
        FeedbackRequest.create!(
          requester: user,
          pair: pair_user,
          topic: 'Shared Topic',
          details: 'Details',
          tag: 'shared-tag',
          visibility: 'public'
        )
      end

      it "returns the request for the pair user" do
        pair_token = JWT.encode({user_id: pair_user.id}, ENV['JWT_SECRET'] || 'test_secret')
        pair_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{pair_token}", 'CONTENT_TYPE' => 'application/json' }

        get '/', {}, pair_headers
        
        expect(last_response.status).to eq(200)
        body = JSON.parse(last_response.body)
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['topic']).to eq('Shared Topic')
        expect(body['items'][0]['pair_username']).to eq(pair_user.username)
        # Verify isOwner is false for pair (conceptually true for viewing, but technical ownership is requester)
        # Actually logic is `isOwner: request.requester_id == current_user.id`
        # So for pair, isOwner is false? The UI might treat 'isOwner' as 'can edit'. 
        # For now, let's just verify visibility.
        expect(body['items'][0]['isOwner']).to eq(false) 
      end
    end
  end

  describe "POST /" do
    let(:valid_params) do
      {
        topic: 'My Code Review',
        details: 'Please review my code.',
        tag: 'code-review',
        visibility: 'public'
      }
    end

    context "when creating a standard request" do
      it "creates a single feedback request" do
        post '/', valid_params.to_json, headers
        expect(last_response.status).to eq(201)
        expect(FeedbackRequest.count).to eq(1)
        expect(FeedbackRequest.first.requester_id).to eq(user.id)
      end
    end

    context "when creating a request with a pair requester" do
      let(:params_with_pair) { valid_params.merge(pair_username: pair_user.username) }

      it "creates a single feedback request associated with both users" do
        post '/', params_with_pair.to_json, headers
        expect(last_response.status).to eq(201)
        expect(FeedbackRequest.count).to eq(1)

        request = FeedbackRequest.first
        expect(request.requester_id).to eq(user.id)
        # We need to access the underlying column or relation. 
        # Since I haven't run migration yet, calling .pair_id will raise NoMethodError, which is a valid failure.
        # But to be clean, let's verify response or attributes
        expect(request.respond_to?(:pair_id)).to be_truthy # This will fail
        expect(request.pair_id).to eq(pair_user.id)
        expect(request.topic).to eq('My Code Review')
      end

      it "grants points/triggers middleware for both users" do
        # We can verify this by checking if QuestMiddleware receives calls or if ActivityStream is created
        # Logic: "QuestMiddleware.trigger(current_user, 'FeedbackRequestsController#create')" is called in existing code
        # We expect it to be called for pair user too.
        
        # Since QuestMiddleware.trigger is a class method, we can spy on it
        allow(QuestMiddleware).to receive(:trigger)
        
        post '/', params_with_pair.to_json, headers
        
        expect(QuestMiddleware).to have_received(:trigger).with(user, 'FeedbackRequestsController#create')
        expect(QuestMiddleware).to have_received(:trigger).with(pair_user, 'FeedbackRequestsController#create')
      end
    end

    context "with invalid pair requester" do
      it "returns an error if pair user not found" do
        params = valid_params.merge(pair_username: 'non_existent_user')
        post '/', params.to_json, headers
        
        expect(last_response.status).to eq(404) # or 422, let's assume 404 for "User not found" or 422 for validation
        body = JSON.parse(last_response.body)
        expect(body['error']).to include('Pair user not found')
      end

      it "returns an error if trying to pair with self" do
        params = valid_params.merge(pair_username: user.username)
        post '/', params.to_json, headers
        
        expect(last_response.status).to eq(422)
        body = JSON.parse(last_response.body)
        expect(body['error']).to include('Cannot pair with yourself')
      end
    end



    context "Edge Cases and Security" do
      let(:params_with_pair) { valid_params.merge(pair_username: pair_user.username) }

      it "handles failures gracefully" do
        # With single request model, transaction rollback for "pair request" is essentially just "save failed".
        # We can simulate save failure by making params invalid.
        # But verify checking specific edge case: Validating pair doesn't break basic request save flow strangely?
        # Actually, if save fails, count stays same.
        
        initial_count = FeedbackRequest.count
        invalid_params = params_with_pair.merge(topic: '') # Invalid topic
        post '/', invalid_params.to_json, headers
        
        expect(last_response.status).to eq(422)
        expect(FeedbackRequest.count).to eq(initial_count)
      end

      it "enforces rate limits for the requester" do
        # Simulate limit reached

        # We need to stub it correctly because it's a constant. 
        # RSpec constant stubbing: stub_const("AppConfig::MAX_DAILY_FEEDBACK_REQUESTS", 0)
        stub_const("AppConfig::MAX_DAILY_FEEDBACK_REQUESTS", 0)

        params = valid_params.merge(pair_username: pair_user.username)
        post '/', params.to_json, headers

        expect(last_response.status).to eq(429)
        expect(FeedbackRequest.count).to eq(0)
      end
    end
  end
end

