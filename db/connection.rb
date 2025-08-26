require 'sqlite3'

DB = SQLite3::Database.new "db/development.sqlite3"

# Return results as hashes (so we can access columns by name)
DB.results_as_hash = true

DB.busy_timeout = 1000