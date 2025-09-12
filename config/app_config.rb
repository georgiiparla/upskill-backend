module AppConfig
  if ENV['RACK_ENV'] == 'production'

    # The lifespan of a feedback request before it auto-closes.
    FEEDBACK_REQUEST_LIFESPAN = 1 * 3600 # 1 hour in seconds
    # How often the app checks for expired requests.
    EXPIRATION_JOB_FREQUENCY = 60 # 1 minute in seconds

  else
    
    FEEDBACK_REQUEST_LIFESPAN = 30 # 30 seconds
    EXPIRATION_JOB_FREQUENCY = 5 # 5 seconds

  end
end