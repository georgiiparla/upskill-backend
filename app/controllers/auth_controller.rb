require 'google/apis/oauth2_v2'
require 'google/api_client/client_secrets'
require_relative '../middleware/quest_middleware'

class AuthController < ApplicationController

  # It generates the Google sign-in URL and redirects the user there.
  get '/google/login' do
    client_secrets = Google::APIClient::ClientSecrets.new(
      "web" => {
        "client_id" => ENV['GOOGLE_CLIENT_ID'],
        "client_secret" => ENV['GOOGLE_CLIENT_SECRET'],
        "redirect_uris" => ["#{request.base_url}/auth/google/callback"],
        "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
        "token_uri" => "https://oauth2.googleapis.com/token"
      }
    )
    authorizer = client_secrets.to_authorization
    authorizer.scope = ['email', 'profile']
    
    # Store the state in the session to prevent CSRF attacks
    session[:state] = SecureRandom.hex(16)
    authorizer.state = session[:state]

    redirect authorizer.authorization_uri.to_s
  end

  # Google redirects the user here after they approve the login.
  get '/google/callback' do
    # First, check the state to ensure the request is legitimate.
    if params['state'] != session[:state]
      halt 401, 'Invalid state parameter'
    end

    client_secrets = Google::APIClient::ClientSecrets.new(
      "web" => {
        "client_id" => ENV['GOOGLE_CLIENT_ID'],
        "client_secret" => ENV['GOOGLE_CLIENT_SECRET'],
        "redirect_uris" => ["#{request.base_url}/auth/google/callback"],
        "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
        "token_uri" => "https://oauth2.googleapis.com/token"
      }
    )
    authorizer = client_secrets.to_authorization
    authorizer.code = params['code']
    authorizer.fetch_access_token!

    # Now use the access token to get the user's profile info
    oauth2_service = Google::Apis::Oauth2V2::Oauth2Service.new
    oauth2_service.authorization = authorizer
    user_info = oauth2_service.get_userinfo

    user = nil
    login_email = user_info.email.downcase

    # 1. Check if the email matches a primary user account
    user = User.find_by('lower(email) = ?', login_email)

    # 2. If not found, check if it matches an alias
    if user.nil?
      alias_entry = UserEmailAlias.find_by('lower(email) = ?', login_email)
      user = alias_entry.user if alias_entry
    end

    # 3. If still no user, check if this email is authorized to create a NEW account
    if user.nil?
      if User.is_creation_authorized?(login_email)
        user = User.new(
          email: user_info.email, # Store with original casing
          username: user_info.name,
          password: SecureRandom.hex(16)
        )
        unless user.save
          redirect "#{ENV['FRONTEND_URL']}/login?error=account_creation_failed"
          return
        end
      else
        # If not found and not authorized to create, it's an unauthorized email.
        redirect "#{ENV['FRONTEND_URL']}/login?error=unauthorized_email"
        return
      end
    end

    # Generate JWT for the found/created user and redirect
    token = encode_token({ user_id: user.id })
    
    # Award daily login quest (5 points per login, once per 24 hours)
    QuestMiddleware.trigger(user, 'AuthController#google_callback')
    
    redirect "#{ENV['FRONTEND_URL']}/auth/callback?token=#{token}"
  end

  post '/logout' do
    json({ message: 'Logout acknowledged' })
  end

  get '/profile' do
    if current_user
      json({ 
        logged_in: true, 
        user: current_user.slice(:id, :username, :email),
        is_admin: is_admin?(current_user)
      })
    else
      json({ logged_in: false })
    end
  end

  # NEW: Stats endpoint for the Account page
  get '/stats' do
    protected!
    
    # Count likes given by current user
    likes_given = FeedbackSubmissionLike.where(user_id: current_user.id).count
    
    # Count likes received on submissions authored by current user
    # joins ensures we only count likes on valid submissions
    likes_received = FeedbackSubmissionLike.joins(:feedback_submission)
                                           .where(feedback_submissions: { user_id: current_user.id })
                                           .count

    json({ 
      likes_given: likes_given, 
      likes_received: likes_received 
    })
  end
end