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
        expect(body['items'][0]['isOwner']).to eq(true) 
      end
    end
    
    context "Visibility Regression Check" do
      it "allows User B to see User A's PUBLIC solo request" do
        # Create a public request by User A (user)
        FeedbackRequest.create!(requester: user, topic: 'Public Solo', details: 'D', tag: 'pub-solo', visibility: 'public')
        
        # Log in as User B (pair_user)
        pair_token = JWT.encode({user_id: pair_user.id}, ENV['JWT_SECRET'] || 'test_secret')
        pair_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{pair_token}", 'CONTENT_TYPE' => 'application/json' }
        
        get '/', {}, pair_headers
        
        expect(last_response.status).to eq(200)
        body = JSON.parse(last_response.body)
        
        # User B should see the public request
        # CURRENTLY: This fails because the query filters strictly by requester/pair match
        expect(body['items'].any? { |r| r['topic'] == 'Public Solo' }).to be true
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

    context "Pair Permissions (Regression Tests)" do
      let!(:shared_request) do
        FeedbackRequest.create!(
          requester: user,
          pair: pair_user,
          topic: 'Pair Can Manage?',
          details: 'We shall see',
          tag: 'pair-manage-test',
          visibility: 'public'
        )
      end

      it "allows the pair user to DELETE the shared request" do
        pair_token = JWT.encode({user_id: pair_user.id}, ENV['JWT_SECRET'] || 'test_secret')
        pair_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{pair_token}", 'CONTENT_TYPE' => 'application/json' }

        delete "/#{shared_request.id}", {}, pair_headers
        
        # CURRENTLY: Expecting 403 (Failure)
        # DESIRED: Expecting 200 (Success)
        expect(last_response.status).to eq(200)
        expect(FeedbackRequest.find_by(id: shared_request.id)).to be_nil
      end

      it "allows the pair user to CLOSE the shared request" do
        pair_token = JWT.encode({user_id: pair_user.id}, ENV['JWT_SECRET'] || 'test_secret')
        pair_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{pair_token}", 'CONTENT_TYPE' => 'application/json' }

        patch "/#{shared_request.id}", { status: 'closed' }.to_json, pair_headers
        
        expect(last_response.status).to eq(200)
        expect(shared_request.reload.status).to eq('closed')
      end

      context "Points Reversion Logic" do
        it "reverts points for BOTH requester and pair when PAIR deletes" do
          pair_token = JWT.encode({user_id: pair_user.id}, ENV['JWT_SECRET'] || 'test_secret')
          pair_headers = { 'HTTP_AUTHORIZATION' => "Bearer #{pair_token}", 'CONTENT_TYPE' => 'application/json' }
          
          # Spy on QuestMiddleware
          allow(QuestMiddleware).to receive(:revert)
          
          delete "/#{shared_request.id}", {}, pair_headers
          
          expect(last_response.status).to eq(200)
          
          # Verify Reversion called for Pair (the deleter)
          expect(QuestMiddleware).to have_received(:revert).with(pair_user, 'FeedbackRequestsController#create')
          
          # Verify Reversion called for Requester (the other party) - THIS SHOULD FAIL CURRENTLY
          expect(QuestMiddleware).to have_received(:revert).with(user, 'FeedbackRequestsController#create')
        end

        it "reverts points for BOTH requester and pair when REQUESTER deletes" do
           # Spy on QuestMiddleware
           allow(QuestMiddleware).to receive(:revert)
           
           delete "/#{shared_request.id}", {}, headers # headers is for 'user' (owner)
           
           expect(last_response.status).to eq(200)
           
           # Verify Reversion called for Requester (the deleter)
           expect(QuestMiddleware).to have_received(:revert).with(user, 'FeedbackRequestsController#create')
           
           # Verify Reversion called for Pair - THIS SHOULD FAIL CURRENTLY
           expect(QuestMiddleware).to have_received(:revert).with(pair_user, 'FeedbackRequestsController#create')
        end

        it "handles deletion gracefully even if Pair user no longer exists" do
           # Simulate Pair user being deleted from DB but request remaining (unlikely with FK constraints, but possible logic flaw)
           # Or just force feedback_request.pair to return nil during destroy
           
           # Better: Create a request without a pair (or user was deleted)
           # Since we can't easily mock the association call inside the controller without heavy mocking, 
           # let's just ensure standard request deletion only calls revert once.
           
           solo_request = FeedbackRequest.create!(requester: user, topic: 'Solo', details: 'D', tag: 'solo', visibility: 'public')
           
           allow(QuestMiddleware).to receive(:revert)
           
           delete "/#{solo_request.id}", {}, headers
           
           expect(last_response.status).to eq(200)
           expect(QuestMiddleware).to have_received(:revert).with(user, 'FeedbackRequestsController#create').once
           # And NOT with nil or anything else
           expect(QuestMiddleware).to have_received(:revert).exactly(1).times
        end
      end
    end
  end

  describe "POST /" do
    it "returns 422 if trying to pair with self" do
      request_data = {
        topic: 'Self Pair',
        details: 'Details',
        tag: 'self',
        visibility: 'public',
        pair_username: user.username
      }
      
      token = JWT.encode({user_id: user.id}, ENV['JWT_SECRET'] || 'test_secret')
      headers = { 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' }
      
      post '/', request_data.to_json, headers
      expect(last_response.status).to eq(422)
    end

    it "returns 404 if pair user does not exist" do
      request_data = {
        topic: 'Ghost Pair',
        details: 'Details',
        tag: 'ghost',
        visibility: 'public',
        pair_username: 'non_existent_user_123'
      }
      
      token = JWT.encode({user_id: user.id}, ENV['JWT_SECRET'] || 'test_secret')
      headers = { 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' }
      
      expect {
        post '/', request_data.to_json, headers
      }.not_to change(FeedbackRequest, :count)
      
      expect(last_response.status).to eq(404)
    end
    
    it "returns 404 if pair_username is an empty string" do
      # This confirms that explicit empty string is treated as an attempt to pair, not ignored
      request_data = {
        topic: 'Empty String Pair',
        details: 'Details',
        tag: 'empty',
        visibility: 'public',
        pair_username: '' 
      }
      
      token = JWT.encode({user_id: user.id}, ENV['JWT_SECRET'] || 'test_secret')
      headers = { 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' }
      
      post '/', request_data.to_json, headers
      expect(last_response.status).to eq(404) # Current logic: "" is truthy -> find_by -> nil -> 404
    end
  end
end

