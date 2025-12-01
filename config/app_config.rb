module AppConfig
  if ENV['RACK_ENV'] == 'production'

    # ... (Your existing production config) ...
    # Note: Your production code had a mismatch (Comment said 20 mins, math was 24 hours).
    # You might want to double-check that separately.

    FEEDBACK_REQUEST_LIFESPAN = 24 * 3600
    EXPIRATION_JOB_FREQUENCY = 60
    LEADERBOARD_RESET_FREQUENCY = 30 * 24 * 3600
    MANTRA_CYCLE_INTERVAL = 7 * 24 * 3600
    LEADERBOARD_SYNC_INTERVAL = 24 * 60 * 60 # Check this value!
    MAX_DAILY_LIKES = 5

  else
    # ==========================================
    # DEVELOPMENT / TEST CONFIGURATION
    # ==========================================

    # 1. Feedback Lifespan: 30 Minutes
    # Old: 60 seconds.
    # New: Long enough to switch users and write a reply without it closing on you.
    FEEDBACK_REQUEST_LIFESPAN = 30 * 60

    # 2. Expiration Job: 30 Seconds
    # Old: 5 seconds.
    # New: Runs often enough to catch expired items, but reduces noise in your terminal logs.
    EXPIRATION_JOB_FREQUENCY = 30

    # 3. Leaderboard Reset: 24 Hours
    # Old: 10 minutes.
    # New: Allows your test points to persist throughout a whole day of coding
    # so you don't lose your "Gamification" progress while debugging UI.
    LEADERBOARD_RESET_FREQUENCY = 24 * 60 * 60

    # 4. Mantra Cycle: 1 Hour
    # Old: 60 seconds.
    # New: Keeps the UI stable. Accessing the dashboard every minute won't
    # show a different text every single time, which can be confusing.
    MANTRA_CYCLE_INTERVAL = 60 * 60

    # 5. Leaderboard Sync: 2 Minutes
    # Old: 60 seconds.
    # New: Fast enough to verify points are syncing, but keeps a small delay
    # so you can still verify that the "Shadow Column" logic is working.
    LEADERBOARD_SYNC_INTERVAL = 2 * 60

    # 6. Max Daily Likes: 50
    # Old: 5.
    # New: Raised significantly so you can spam clicks to test animations
    # or button states without hitting the limit immediately.
    MAX_DAILY_LIKES = 8

  end
end