require 'spec_helper'

RSpec.describe FeedbackRequestsController do
  def app
    FeedbackRequestsController
  end

  let!(:user) { User.create(username: 'tester', email: 'tester@example.com', password: 'password') }
  let!(:pair_user) { User.create(username: 'pair_buddy', email: 'pair@example.com', password: 'password') }
  let(:token) { JWT.encode({user_id: user.id}, ENV['JWT_SECRET'] || 'test_secret') }
  let(:headers) { { 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' } }

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

      it "creates two feedback requests (one for requester, one for pair)" do
        post '/', params_with_pair.to_json, headers
        expect(last_response.status).to eq(201)
        expect(FeedbackRequest.count).to eq(2)

        # Check user's request
        user_req = FeedbackRequest.find_by(requester_id: user.id)
        expect(user_req).not_to be_nil
        expect(user_req.topic).to eq('My Code Review')

        # Check pair's request
        pair_req = FeedbackRequest.find_by(requester_id: pair_user.id)
        expect(pair_req).not_to be_nil
        expect(pair_req.topic).to eq('My Code Review')
        
        # Ensure tags are unique (since tag must be unique)
        # The implementation should handle tag uniqueness for the pair, likely by appending something
        # or generating a new tag. For now we assume the implementation will handle it.
        # But wait, if we send 'tag', validation says `validates :tag, presence: true, uniqueness: true`
        # So the second request MUST have a different tag.
        expect(user_req.tag).not_to eq(pair_req.tag)
        expect(pair_req.tag).to include(valid_params[:tag])
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
      it "rolls back the transaction if pair request creation fails" do
        # Create a request for the pair user that will cause a tag collision
        # The code generates tag: "#{params[:tag]}-#{pair_user.username}"
        expected_pair_tag = "#{valid_params[:tag]}-#{pair_user.username}"
        FeedbackRequest.create!(
          requester: pair_user,
          topic: 'Collision Stopper',
          tag: expected_pair_tag,
          visibility: 'public'
        )

        initial_count = FeedbackRequest.count
        
        # Try to create a pair request that would generate the same tag
        params = valid_params.merge(pair_username: pair_user.username)
        post '/', params.to_json, headers

        expect(last_response.status).to eq(500).or eq(422) 
        
        # Verify no changes in DB
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

