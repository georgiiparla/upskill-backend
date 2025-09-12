require 'google/apis/oauth2_v2'
require 'google/api_client/client_secrets'

class AuthController < ApplicationController

  # This is the new endpoint our frontend will link to.
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

    # Find or Create User (same logic as before)
    user = User.find_by(email: user_info.email)
    unless user
      user = User.new(
        email: user_info.email,
        username: user_info.name,
        password: SecureRandom.hex(16)
      )
      unless user.save
        redirect "#{ENV['FRONTEND_URL']}/login?error=account_creation_failed"
        return
      end
    end

    # Generate JWT and redirect to frontend
    token = encode_token({ user_id: user.id })
    redirect "#{ENV['FRONTEND_URL']}/auth/callback?token=#{token}"
  end

  post '/logout' do
    json({ message: 'Logout acknowledged' })
  end

  get '/profile' do
    if current_user
      json({ logged_in: true, user: current_user.slice(:id, :username, :email) })
    else
      json({ logged_in: false })
    end
  end
end