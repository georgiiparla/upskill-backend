class AdminController < ApplicationController
  get '/users' do
    admin_protected!
    
    all_users = User.order(created_at: :desc)
    
    users_json = all_users.map do |user|
      {
        username: user.username,
        email: user.email,
        created_at: user.created_at
      }
    end

    json users_json
  end

  post '/jobs/:job_name' do
    admin_protected!
    
    job_name = params['job_name']
    allowed_jobs = ['feedback_expiration_job', 'leaderboard_reset_job', 'leaderboard_sync_job', 'quest_reset_job']
    
    unless allowed_jobs.include?(job_name)
      json_error("Invalid job name. Allowed: #{allowed_jobs.join(', ')}")
    end
    
    # Clear the cache to force execution
    settings.job_check_cache.delete(job_name)
    
    # Dynamically call the job method
    method_name = "run_#{job_name}"
    
    if respond_to?(method_name, true)
      send(method_name, force: true)
      json({ message: "Job '#{job_name}' triggered successfully." })
    else
      json_error("Job method '#{method_name}' not found.", 500)
    end
  end

  get '/jobs' do
    admin_protected!
    
    # Leaderboard Reset Job Next Run
    reset_rec = SystemSetting.find_by(key: 'last_leaderboard_reset_run')
    last_reset = reset_rec ? (Time.parse(reset_rec.value) rescue nil) : nil
    next_reset = last_reset ? (last_reset + AppConfig::LEADERBOARD_RESET_FREQUENCY.seconds).iso8601 : nil

    # Sync Job Next Run
    sync_rec = SystemSetting.find_by(key: 'last_leaderboard_sync')
    last_sync = sync_rec ? (Time.parse(sync_rec.value) rescue nil) : nil
    next_sync = last_sync ? (last_sync + AppConfig::LEADERBOARD_SYNC_INTERVAL.seconds).iso8601 : nil

    jobs = [
      { 
        id: 'leaderboard_reset_job', 
        label: 'Reset Leaderboard', 
        description: 'Resets points for the new cycle',
        next_run_date: next_reset
      },
      { 
        id: 'leaderboard_sync_job', 
        label: 'Sync Leaderboard', 
        description: 'Syncs public points with shadow points',
        next_run_date: next_sync
      },
      { 
        id: 'quest_reset_job', 
        label: 'Reset Quests', 
        description: 'Resets progress for interval-based quests',
        next_run_date: nil # Complex to calculate globally, omitting
      }
    ]

    json jobs
  end

  get '/env' do
    admin_protected!
    
    # 1. Specific Whitelisted ENV Vars
    whitelist = ['ALLOWED_DOMAIN', 'WHITELISTED_EMAILS', 'ADMIN_EMAILS']
    env_data = whitelist.map do |key|
      { key: key, value: ENV[key] }
    end

    # 2. AppConfig Constants
    # We iterate over the constants defined in the AppConfig module
    app_config_data = AppConfig.constants.map do |const_name|
      { key: const_name.to_s, value: AppConfig.const_get(const_name) }
    end

    # Combine and sort by key
    combined = (env_data + app_config_data).sort_by { |item| item[:key] }
    
    json combined
  end
end