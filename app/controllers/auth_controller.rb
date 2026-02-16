require 'google/apis/oauth2_v2'
require 'google/api_client/client_secrets'
require_relative '../middleware/quest_middleware'

class AuthController < ApplicationController

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
    
    state_payload = { 
      nonce: SecureRandom.hex(16), 
      exp: Time.now.to_i + 600 
    }
    state_token = JWT.encode(state_payload, jwt_secret, 'HS256')
    
    authorizer.state = state_token

    redirect authorizer.authorization_uri.to_s
  end

  get '/google/callback' do
    begin
      JWT.decode(params['state'], jwt_secret, true, { algorithm: 'HS256' })
    rescue JWT::DecodeError, JWT::ExpiredSignature
      json_error('Invalid state parameter', 401)
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

    oauth2_service = Google::Apis::Oauth2V2::Oauth2Service.new
    oauth2_service.authorization = authorizer
    user_info = oauth2_service.get_userinfo

    user = nil
    login_email = user_info.email.downcase

    user = User.find_by('lower(email) = ?', login_email)

    if user.nil?
      alias_entry = UserEmailAlias.find_by('lower(email) = ?', login_email)
      user = alias_entry.user if alias_entry
    end

    if user.nil?
      if User.is_creation_authorized?(login_email)
        user = User.new(
          email: user_info.email,
          username: user_info.name,
          password: SecureRandom.hex(16)
        )
        unless user.save
          redirect "#{ENV['FRONTEND_URL']}/login?error=account_creation_failed"
          return
        end
      else
        redirect "#{ENV['FRONTEND_URL']}/login?error=unauthorized_email"
        return
      end
    end

    token = encode_token({ user_id: user.id })
    
    QuestMiddleware.trigger(user, 'AuthController#google_callback')
    
    # Set the secure, HttpOnly cookie directly from the backend
    response.set_cookie('token', {
      value: token,
      path: '/',
      expires: Time.now + (24 * 60 * 60),
      domain: '.demoplatform.app',
      secure: true,
      same_site: :none,
      httponly: true
    })

    redirect "#{ENV['FRONTEND_URL']}/dashboard"
  end

  post '/logout' do
    response.delete_cookie('token', {
      path: '/',
      domain: '.demoplatform.app'
    })

    # Extra safety
    response.delete_cookie('token', { path: '/' })

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

  get '/stats' do
    protected!
    
    likes_given = FeedbackSubmissionLike.where(user_id: current_user.id).count
    likes_received = FeedbackSubmissionLike.joins(:feedback_submission)
                                           .where(feedback_submissions: { user_id: current_user.id })
                                           .count

    json({ 
      likes_given: likes_given, 
      likes_received: likes_received 
    })
  end
end