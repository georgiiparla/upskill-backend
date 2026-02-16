require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'bcrypt'
require 'logger'
require 'jwt'
require 'time'

require_relative '../../config/app_config'

Dir["./app/models/*.rb"].each { |file| require file }

class ApplicationController < Sinatra::Base

  set :database_file, '../../config/database.yml'

  configure do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    set :logger, logger
    use Rack::CommonLogger, logger
    
    set :job_check_cache, {}
    set :job_check_cache_ttl, 10 
    
    # In-memory rate limiting cache for search: { user_id => last_search_timestamp }
    set :search_rate_limit_cache, {} 


  end
  
  helpers do

    def should_check_job?(job_key)
      cache = settings.job_check_cache
      last_check = cache[job_key]
      
      if last_check.nil? || (Time.now - last_check) > settings.job_check_cache_ttl
        cache[job_key] = Time.now
        true
      else
        false
      end
    end

    def check_search_rate_limit!(user_id)
      cache = settings.search_rate_limit_cache
      last_search = cache[user_id]
      
      # Limit: 1 request per 0.5 seconds
      if last_search && (Time.now - last_check_timestamp(last_search)) < 0.5
        halt 429, json({ error: 'Too many requests. Please slow down.' })
      end
      cache[user_id] = Time.now
    end
    
    def last_check_timestamp(time_val)
      time_val
    end

    def jwt_secret
      ENV['JWT_SECRET']
    end

    def encode_token(payload)
      payload[:exp] = Time.now.to_i + (24 * 60 * 60) 
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

    def admin_protected!
      halt 401, json({ error: 'Unauthorized' }) unless current_user
      halt 403, json({ error: 'Access denied. Admin privileges required.' }) unless is_admin?(current_user)
    end

    def is_admin?(user)
      return false unless user&.email
      admin_emails = ENV['ADMIN_EMAILS']&.split(',')&.map(&:strip) || []
      admin_emails.include?(user.email)
    end

    # Safer find-or-create for SystemSetting
    def find_or_create_system_setting_safely(key)
      rec = SystemSetting.find_by(key: key)
      unless rec
        begin
          rec = SystemSetting.create!(key: key, value: (Time.now - 1.year).utc.iso8601)
        rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
          rec = SystemSetting.find_by(key: key)
        end
      end
      rec
    end

    # Traffic-based job: Close expired feedback requests
    def run_feedback_expiration_job(force: false)
      return unless force || should_check_job?('expiration_job')
      key = 'last_expiration_run'

      SystemSetting.transaction do
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        return unless force || (Time.now > last + AppConfig::EXPIRATION_JOB_FREQUENCY.seconds)

        begin
          settings.logger.info "Running job to close expired requests..."
          expired_requests = FeedbackRequest.where(status: 'pending').where('expires_at < ?', Time.now)

          if expired_requests.any?
            expired_requests.each do |req|
              ActivityStream.create(actor: nil, event_type: 'feedback_closed', target: req)
            end
            count = expired_requests.update_all(status: 'closed')
            settings.logger.info "Closed #{count} expired request(s)."
          end
          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Expiration job failed: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    # Traffic-based job: Reset leaderboard points monthly
    def run_leaderboard_reset_job(force: false)
      return unless force || should_check_job?('leaderboard_reset_job')
      key = 'last_leaderboard_reset_run'

      SystemSetting.transaction do
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        return unless force || (Time.now > last + AppConfig::LEADERBOARD_RESET_FREQUENCY.seconds)

        begin
          settings.logger.info "Running monthly leaderboard reset job..."
          reset_count = Leaderboard.update_all(points: 0, public_points: 0)
          settings.logger.info "Reset points for #{reset_count} user(s) in leaderboard."
          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Leaderboard reset job failed: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    # Traffic-based job: Sync public leaderboard points
    def run_leaderboard_sync_job(force: false)
      return unless force || should_check_job?('leaderboard_sync_job')
      key = 'last_leaderboard_sync'

      SystemSetting.transaction do
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        
        return unless force || (Time.now > last + AppConfig::LEADERBOARD_SYNC_INTERVAL.seconds)

        begin
          settings.logger.info "Running leaderboard sync job (Shadow Column Sync)..."
          Leaderboard.update_all(['public_points = points, updated_at = ?', Time.now])
          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Leaderboard sync job failed: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    # Traffic-based job: Reset interval-based quests
    def run_quest_reset_job(force: false)
      return unless force || should_check_job?('quest_reset_job')

      Quest.where.not(reset_interval_seconds: nil).find_each do |quest|
        begin
          if force || quest.should_reset_globally?
            settings.logger.info "Resetting quest: #{quest.title} (ID: #{quest.id})"
            quest.reset_all_users!
          end
        rescue => e
          settings.logger.error "Quest reset failed for quest #{quest.id}: #{e.message}"
        end
      end
    end
  end

  before do
    # Traffic-based cron jobs - run on every request if enough time has passed
    begin
      run_feedback_expiration_job
      run_leaderboard_reset_job
      run_leaderboard_sync_job
      run_quest_reset_job
    rescue => e
      settings.logger.error "Background job failed: #{e.class} - #{e.message}"
    end

    @request_payload = {}
    body = request.body&.read
    if body && !body.empty? && request.content_type&.include?("application/json")
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end

  # --- Centralized Error Handling ---

  error do
    e = env['sinatra.error']
    settings.logger.error "Unhandled Exception: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
    
    status 500
    response = { error: 'Internal Server Error' }
    
    # Only expose detailed messages if specifically enabled or in development
    if ENV['RACK_ENV'] == 'development'
      response[:message] = e.message
      response[:type] = e.class.name
    end
    
    json(response)
  end

  not_found do
    status 404
    json({ error: 'Not Found', message: "The requested resource '#{request.path}' was not found." })
  end

  helpers do
    def json_error(error_or_errors, code = 400)
      if error_or_errors.is_a?(Array)
        halt code, json({ errors: error_or_errors })
      else
        halt code, json({ error: error_or_errors })
      end
    end
  end
end