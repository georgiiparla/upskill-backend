module AppConfig
  if ENV['RACK_ENV'] == 'production'

    # The lifespan of a feedback request before it auto-closes.
    FEEDBACK_REQUEST_LIFESPAN = 24 * 3600 # in seconds
    # How often the app checks for expired requests.
    EXPIRATION_JOB_FREQUENCY = 60 # in seconds
    # How often to reset leaderboard points (monthly)
    LEADERBOARD_RESET_FREQUENCY = 30 * 24 * 3600 # in seconds (1 month)
    # How often to cycle mantras (weekly)
    MANTRA_CYCLE_INTERVAL = 7 * 24 * 3600 # in seconds (1 week)

  else
    
    FEEDBACK_REQUEST_LIFESPAN = 2 * 30
    EXPIRATION_JOB_FREQUENCY = 5
    # For development/testing: reset leaderboard every 5 minutes
    LEADERBOARD_RESET_FREQUENCY = 5 * 60 # in seconds
    # For development/testing: cycle mantras every 20 seconds
    MANTRA_CYCLE_INTERVAL = 60 # in seconds

  end
end