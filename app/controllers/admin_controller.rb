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
      halt 400, json({ error: "Invalid job name. Allowed: #{allowed_jobs.join(', ')}" })
    end
    
    begin
      # Clear the cache to force execution
      settings.job_check_cache.delete(job_name)
      
      # Dynamically call the job method
      method_name = "run_#{job_name}"
      
      if respond_to?(method_name, true)
        send(method_name, force: true)
        json({ message: "Job '#{job_name}' triggered successfully." })
      else
        halt 500, json({ error: "Job method '#{method_name}' not found." })
      end
    rescue => e
      halt 500, json({ error: "Job execution failed: #{e.message}" })
    end
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