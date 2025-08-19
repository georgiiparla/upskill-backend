# This file is loaded first and sets up the testing environment.

# Set the environment to 'test' to use the test database and configurations
ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'rack'
require 'sqlite3'
require 'json'
require 'bcrypt'
require 'fileutils'

# --- RSpec Configuration ---
RSpec.configure do |config|
  # Include Rack::Test methods (like get, post, last_response) in all spec files
  config.include Rack::Test::Methods

  # --- Define the app method for Rack::Test ---
  # This tells our tests to make requests against the application defined in config.ru
  def app
    # FIX: parse_file returns the fully configured Rack app, not an array.
    Rack::Builder.parse_file('config.ru')
  end

  # --- Database Setup and Teardown ---
  # This block runs once before the entire test suite starts.
  config.before(:suite) do
    puts "Setting up the test database..."

    # Ensure the db directory exists
    FileUtils.mkdir_p('db')
    
    # Use a separate database file for testing to avoid conflicts
    test_db_path = 'db/test.sqlite3'
    
    # Connect to the test database
    DB = SQLite3::Database.new(test_db_path)
    DB.results_as_hash = true
    DB.busy_timeout = 1000

    # Read the schema and seed SQL files
    schema_sql = File.read('db/schema.sql')
    seeds_sql = File.read('db/seeds.sql')

    # Execute the SQL to create tables and insert seed data
    DB.execute_batch(schema_sql)
    DB.execute_batch(seeds_sql)

    # Manually add a test user since the seeds file doesn't have a predictable password
    password_digest = BCrypt::Password.create('password123')
    DB.execute(
      "INSERT OR REPLACE INTO users (id, username, email, password_digest) VALUES (?, ?, ?, ?)",
      1, 'Test User', 'test@example.com', password_digest
    )
    puts "Test database setup complete."
  end

  # --- Clean up after the suite ---
  config.after(:suite) do
    puts "\nCleaning up test database..."
    DB.close if DB
    File.delete('db/test.sqlite3') if File.exist?('db/test.sqlite3')
    puts "Cleanup complete."
  end
  
  # This clears cookies between tests to ensure a clean state
  config.before(:each) do
    clear_cookies
  end

  # --- RSpec Expectation and Mocking Configuration ---
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end