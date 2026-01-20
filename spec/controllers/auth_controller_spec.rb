require_relative '../spec_helper'
require_relative '../../app/controllers/auth_controller'

RSpec.describe AuthController do
  def app
    AuthController
  end

  describe "GET /google/login" do
    before do
       allow(ENV).to receive(:[]).and_call_original
       allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_ID').and_return('mock_id')
       allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_SECRET').and_return('mock_secret')
       
       secrets = double("Secrets", to_authorization: double("Auth", :state= => nil, :scope= => nil, :authorization_uri => URI("http://accounts.google.com")))
       allow(Google::APIClient::ClientSecrets).to receive(:new).and_return(secrets)
    end

    it "redirects to Google" do
      get '/google/login'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to include('accounts.google.com')
    end
  end

  describe "GET /google/callback" do
    let(:secret) { ENV['JWT_SECRET'] || 'test_secret' }
    let(:valid_state_token) { JWT.encode({ nonce: '123', exp: Time.now.to_i + 300 }, secret, 'HS256') }
    let(:expired_state_token) { JWT.encode({ nonce: '123', exp: Time.now.to_i - 300 }, secret, 'HS256') }
    
    let(:google_client_secrets) { double("Google::APIClient::ClientSecrets") }
    let(:authorizer) { double("Google::Auth::UserAuthorizer") }
    let(:credentials) { double("Credentials", access_token: "mock_token") }
    let(:oauth2_service) { double("Google::Apis::Oauth2V2::Oauth2Service") }
    
    # User Info Mocks
    let(:primary_email) { "primary@example.com" }
    let(:alias_email) { "alias@example.com" }
    let(:new_allowed_email) { "new@allowed.com" }
    let(:unauthorized_email) { "hacker@random.com" }
    
    let(:user_info_primary) { double("UserInfo", email: primary_email, name: "Primary User") }
    let(:user_info_alias) { double("UserInfo", email: alias_email, name: "Alias User") }
    let(:user_info_new) { double("UserInfo", email: new_allowed_email, name: "New User") }
    let(:user_info_unauthorized) { double("UserInfo", email: unauthorized_email, name: "Bad User") }

    before do
      # Google API Mocks
      allow(Google::APIClient::ClientSecrets).to receive(:new).and_return(google_client_secrets)
      allow(google_client_secrets).to receive(:to_authorization).and_return(authorizer)
      allow(authorizer).to receive(:code=)
      allow(authorizer).to receive(:fetch_access_token!)
      allow(Google::Apis::Oauth2V2::Oauth2Service).to receive(:new).and_return(oauth2_service)
      allow(oauth2_service).to receive(:authorization=)
      
      # Environment Mocks for Authorization
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('JWT_SECRET').and_return(secret)
      allow(ENV).to receive(:[]).with('ALLOWED_DOMAIN').and_return('allowed.com')
      allow(ENV).to receive(:[]).with('WHITELISTED_EMAILS').and_return('whitelist@test.com')
      allow(ENV).to receive(:[]).with('FRONTEND_URL').and_return('http://localhost:3000')

      # Quest Middleware Mock
      allow(QuestMiddleware).to receive(:trigger)
    end

    context "Security & State Validation" do
      it "accepts a valid JWT state parameter" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_primary)
        allow(User).to receive(:find_by).with('lower(email) = ?', primary_email).and_return(double("User", id: 1))
        
        get '/google/callback', { state: valid_state_token, code: 'mock_code' }
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to include('/auth/callback')
      end
      
      it "rejects an invalid JWT state signature" do
        get '/google/callback', { state: 'invalid_token', code: 'mock_code' }
        expect(last_response.status).to eq(401)
        expect(last_response.body).to include('Invalid state parameter')
      end

      it "rejects an expired JWT state" do
        get '/google/callback', { state: expired_state_token, code: 'mock_code' }
        expect(last_response.status).to eq(401)
        expect(last_response.body).to include('Invalid state parameter')
      end
    end

    context "Account Lookup & Creation" do
      before do
        # Use valid state for logic tests
        allow(JWT).to receive(:decode).and_return([{'nonce' => '123'}]) 
      end

      it "logs in successfully with an existing Primary Email" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_primary)
        mock_user = double("User", id: 1, email: primary_email)
        expect(User).to receive(:find_by).with('lower(email) = ?', primary_email).and_return(mock_user)
        
        get '/google/callback', { state: valid_state_token, code: 'code' }
        
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to include("token=")
        expect(QuestMiddleware).to have_received(:trigger).with(mock_user, anything)
      end

      it "logs in successfully with an Email Alias" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_alias)
        
        # 1. Primary lookup fails
        expect(User).to receive(:find_by).with('lower(email) = ?', alias_email).and_return(nil)
        
        # 2. Alias lookup succeeds
        parent_user = double("User", id: 99)
        mock_alias = double("Alias", user: parent_user)
        expect(UserEmailAlias).to receive(:find_by).with('lower(email) = ?', alias_email).and_return(mock_alias)

        get '/google/callback', { state: valid_state_token, code: 'code' }

        expect(last_response.status).to eq(302)
        # Token should be for parent user
        # We can't decode the token here easily without helper, but we verify success flow
        expect(QuestMiddleware).to have_received(:trigger).with(parent_user, anything)
      end

      it "creates a NEW account if email is authorized (Domain Whitelist)" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_new) # @allowed.com
        
        # Not found as primary or alias
        expect(User).to receive(:find_by).and_return(nil)
        expect(UserEmailAlias).to receive(:find_by).and_return(nil)
        
        # Creation Authorized? Yes, domain match.
        # It's an integration test so specific model logic is executed.
        # We stubbed ENV['ALLOWED_DOMAIN'] = 'allowed.com'
        
        # Expect creation
        new_user = double("User", id: 101, save: true)
        expect(User).to receive(:new).with(hash_including(email: new_allowed_email)).and_return(new_user)
        
        get '/google/callback', { state: valid_state_token, code: 'code' }

        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to include("token=")
      end

      it "redirects to error if email is Unauthorized" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_unauthorized)
        
        expect(User).to receive(:find_by).and_return(nil)
        expect(UserEmailAlias).to receive(:find_by).and_return(nil)
        
        # Logic should fail authorization
        
        get '/google/callback', { state: valid_state_token, code: 'code' }
        
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to include("error=unauthorized_email")
      end

      it "redirects to error if Account Creation fails (Db Error)" do
        allow(oauth2_service).to receive(:get_userinfo).and_return(user_info_new)
        
        expect(User).to receive(:find_by).and_return(nil)
        expect(UserEmailAlias).to receive(:find_by).and_return(nil)
        
        # Simulate Save Failure
        bad_user = double("User", id: nil, save: false)
        allow(User).to receive(:new).and_return(bad_user)
        
        get '/google/callback', { state: valid_state_token, code: 'code' }
        
        expect(last_response.status).to eq(302)
        expect(last_response.headers['Location']).to include("error=account_creation_failed")
      end
    end
  end
end
