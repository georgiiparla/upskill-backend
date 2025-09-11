# module AppConfig
#   # The lifespan of a feedback request before it auto-closes.
#   # For production, you could set this to 8 * 3600 (8 hours).
#   FEEDBACK_REQUEST_LIFESPAN = 30 # seconds

#   # How often the app checks for expired requests.
#   EXPIRATION_JOB_FREQUENCY = 5 # seconds
# end

module AppConfig
  # The lifespan of a feedback request before it auto-closes.
  # For production, you could set this to 8 * 3600 (8 hours).
  FEEDBACK_REQUEST_LIFESPAN = 1 * 3600 # seconds

  # How often the app checks for expired requests.
  EXPIRATION_JOB_FREQUENCY = 60 # seconds
end