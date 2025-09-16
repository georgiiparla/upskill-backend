module AppConfig
  if ENV['RACK_ENV'] == 'production'

    # The lifespan of a feedback request before it auto-closes.
    FEEDBACK_REQUEST_LIFESPAN = 24 * 3600 # in seconds
    # How often the app checks for expired requests.
    EXPIRATION_JOB_FREQUENCY = 60 # in seconds

  else
    
    FEEDBACK_REQUEST_LIFESPAN = 2 * 30
    EXPIRATION_JOB_FREQUENCY = 5

  end
end