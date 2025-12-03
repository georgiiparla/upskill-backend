module AppConfig
  if ENV['RACK_ENV'] == 'production'
    # Production Configuration
    FEEDBACK_REQUEST_LIFESPAN = 3 * 24 * 3600       
    EXPIRATION_JOB_FREQUENCY = 120               
    LEADERBOARD_RESET_FREQUENCY = 30 * 24 * 3600 
    MANTRA_CYCLE_INTERVAL = 7 * 24 * 3600       
    LEADERBOARD_SYNC_INTERVAL = 5 * 24 * 3600            
    MAX_DAILY_FEEDBACK_REQUESTS = 3
    MAX_DAILY_LIKES = 10
  else
    # Development / Test Configuration
    FEEDBACK_REQUEST_LIFESPAN = 30 * 60         
    EXPIRATION_JOB_FREQUENCY = 60               
    LEADERBOARD_RESET_FREQUENCY = 0.25 * 3600     
    MANTRA_CYCLE_INTERVAL = 300                
    LEADERBOARD_SYNC_INTERVAL = 300             
    MAX_DAILY_FEEDBACK_REQUESTS = 10
    MAX_DAILY_LIKES = 10
  end
end