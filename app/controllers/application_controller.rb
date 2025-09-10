require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'bcrypt'
require 'logger'
require 'jwt'

Dir["./app/models/*.rb"].each { |file| require file }

class ApplicationController < Sinatra::Base
  set :database_file, '../../config/database.yml'

  configure do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    set :logger, logger
    use Rack::CommonLogger, logger
  end
  
  helpers do
    def jwt_secret
      ENV['JWT_SECRET'] || 'dfb4d95774044fb093def2b7f4788322b4d7cf9970ccbd0d3e516bb31fefa7e7a932fcd88e0da4d0a6dc5c02ccf2f5a26cc59d3899bd9492fd37ce4c1fe75393'
    end

    def encode_token(payload)
      payload[:exp] = Time.now.to_i + 86400 
      JWT.encode(payload, jwt_secret)
    end

    def decoded_token
      auth_header = request.env['HTTP_AUTHORIZATION']
      if auth_header
        token = auth_header.split(' ')[1]
        begin
          JWT.decode(token, jwt_secret, true, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end

    def current_user
      if decoded_token
        user_id = decoded_token[0]['user_id']
        @current_user ||= User.find_by(id: user_id)
        settings.logger.info "User found via JWT: #{@current_user ? "Yes, ID: #{@current_user.id}" : 'No'}"
      end

      @current_user
    end

    def protected!
      halt 401, json({ error: 'Unauthorized' }) unless current_user
    end
  end

  before do
    @request_payload = {}
    body = request.body.read
    if !body.empty? && request.content_type&.include?("application/json")
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end
end