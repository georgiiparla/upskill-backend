require 'sqlite3'

# Create a new SQLite3 database file in the db directory
DB = SQLite3::Database.new "db/development.sqlite3"

# Return results as hashes (so we can access columns by name)
DB.results_as_hash = true

# NEW: Wait up to 1 second (1000ms) if the database is locked
# before throwing an exception.
DB.busy_timeout = 1000