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
    
    # In-memory cache for job check throttling (reduces DB queries)
    set :job_check_cache, {}
    set :job_check_cache_ttl, 300 # seconds
  end
  
  helpers do

    # Check if enough time has passed since last check (in-memory cache to reduce DB queries)
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

    # Safer find-or-create for SystemSetting to avoid a race where two
    # processes try to create the same key concurrently (Postgres / Supabase).
    def find_or_create_system_setting_safely(key)
      rec = SystemSetting.find_by(key: key)
      unless rec
        begin
          rec = SystemSetting.create!(key: key, value: (Time.now - 1.year).utc.iso8601)
        rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
          # concurrent creator; fetch the existing record
          rec = SystemSetting.find_by(key: key)
        end
      end
      rec
    end

    # Traffic-based job: Close expired feedback requests (DB-backed coordination)
    def run_feedback_expiration_job
      return unless should_check_job?('expiration_job')
      
      key = 'last_expiration_run'

      SystemSetting.transaction do
        # create the setting safely if missing, then acquire FOR UPDATE on the row
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        return unless Time.now > last + AppConfig::EXPIRATION_JOB_FREQUENCY.seconds

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

          # update last-run only on success
          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Expiration job failed: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    # Traffic-based job: Reset quest progress weekly (DB-backed coordination)
    def run_quest_reset_job
      return unless should_check_job?('quest_reset_job')
      
      key = 'last_quest_reset_run'

      SystemSetting.transaction do
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        return unless Time.now > last + AppConfig::QUEST_RESET_FREQUENCY.seconds

        begin
          settings.logger.info "Running weekly quest reset job..."

          reset_count = UserQuest.where(completed: true).update_all(completed: false, progress: 0)
          settings.logger.info "Reset #{reset_count} completed quest(s)."

          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Quest reset job failed: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    # Traffic-based job: Reset leaderboard points monthly (DB-backed coordination)
    def run_leaderboard_reset_job
      return unless should_check_job?('leaderboard_reset_job')
      
      key = 'last_leaderboard_reset_run'

      SystemSetting.transaction do
        rec = find_or_create_system_setting_safely(key)
        rec = SystemSetting.lock.find_by(id: rec.id)
        last = (Time.parse(rec.value) rescue Time.now - 1.year)
        return unless Time.now > last + AppConfig::LEADERBOARD_RESET_FREQUENCY.seconds

        begin
          settings.logger.info "Running monthly leaderboard reset job..."

          reset_count = Leaderboard.update_all(points: 0)
          settings.logger.info "Reset points for #{reset_count} user(s) in leaderboard."

          rec.update!(value: Time.now.utc.iso8601)
        rescue => e
          settings.logger.error "Leaderboard reset job failed: #{e.message}"
          raise ActiveRecord::Rollback
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