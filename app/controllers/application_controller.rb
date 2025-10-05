require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'bcrypt'
require 'logger'
require 'jwt'

require_relative '../../config/app_config'

Dir["./app/models/*.rb"].each { |file| require file }

# Global state for traffic-based job scheduling
$last_expiration_run ||= Time.now - 1.year
$last_quest_reset_run ||= Time.now - 1.year
$last_leaderboard_reset_run ||= Time.now - 1.year
$expiration_lock ||= Mutex.new
$quest_reset_lock ||= Mutex.new
$leaderboard_reset_lock ||= Mutex.new

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

    # Traffic-based job: Close expired feedback requests
    def run_feedback_expiration_job
      return unless Time.now > $last_expiration_run + AppConfig::EXPIRATION_JOB_FREQUENCY.seconds
      
      $expiration_lock.synchronize do
        return unless Time.now > $last_expiration_run + AppConfig::EXPIRATION_JOB_FREQUENCY.seconds
        
        begin
          logger.info "Running job to close expired requests..."
          
          expired_requests = FeedbackRequest.where(status: 'pending').where('expires_at < ?', Time.now)
          
          if expired_requests.any?
            expired_requests.each do |req|
              ActivityStream.create(actor: nil, event_type: 'feedback_closed', target: req)
            end
            
            count = expired_requests.update_all(status: 'closed')
            logger.info "Closed #{count} expired request(s)."
          end
        rescue => e
          logger.error "Expiration job failed: #{e.message}"
        ensure
          $last_expiration_run = Time.now
        end
      end
    end

    # Traffic-based job: Reset quest progress weekly
    def run_quest_reset_job
      return unless Time.now > $last_quest_reset_run + AppConfig::QUEST_RESET_FREQUENCY.seconds
      
      $quest_reset_lock.synchronize do
        return unless Time.now > $last_quest_reset_run + AppConfig::QUEST_RESET_FREQUENCY.seconds
        
        begin
          logger.info "Running weekly quest reset job..."
          
          # Reset completed flag and progress for all user quests
          reset_count = UserQuest.where(completed: true).update_all(completed: false, progress: 0)
          logger.info "Reset #{reset_count} completed quest(s)."
        rescue => e
          logger.error "Quest reset job failed: #{e.message}"
        ensure
          $last_quest_reset_run = Time.now
        end
      end
    end

    # Traffic-based job: Reset leaderboard points monthly
    def run_leaderboard_reset_job
      return unless Time.now > $last_leaderboard_reset_run + AppConfig::LEADERBOARD_RESET_FREQUENCY.seconds
      
      $leaderboard_reset_lock.synchronize do
        return unless Time.now > $last_leaderboard_reset_run + AppConfig::LEADERBOARD_RESET_FREQUENCY.seconds
        
        begin
          logger.info "Running monthly leaderboard reset job..."
          
          reset_count = Leaderboard.update_all(points: 0)
          logger.info "Reset points for #{reset_count} user(s) in leaderboard."
        rescue => e
          logger.error "Leaderboard reset job failed: #{e.message}"
        ensure
          $last_leaderboard_reset_run = Time.now
        end
      end
    end
  end

  before do
    # Traffic-based cron jobs - run on every request if enough time has passed
    run_feedback_expiration_job
    run_quest_reset_job
    run_leaderboard_reset_job

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