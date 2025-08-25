This file is a merged representation of a subset of the codebase, containing files not matching ignore patterns, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching these patterns are excluded: vendor
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
.gitignore
app/controllers/application_controller.rb
app/controllers/auth_controller.rb
app/controllers/dashboard_controller.rb
app/controllers/feedback_controller.rb
app/controllers/leaderboard_controller.rb
app/controllers/quests_controller.rb
backend.md
config.ru
db/connection.rb
db/schema.sql
db/seeds.sql
Gemfile
Rakefile
spec/controllers/auth_controller_spec.rb
spec/controllers/dashboard_controller_spec.rb
spec/controllers/feedback_controller_spec.rb
spec/controllers/leaderboard_controller_spec.rb
spec/controllers/protected_routes_spec.rb
spec/controllers/quests_controller_spec.rb
spec/spec_helper.rb
```

# Files

## File: app/controllers/auth_controller.rb
````ruby
require 'sinatra/json'
require 'bcrypt'
require_relative './application_controller'

class AuthController < ApplicationController
  # SIGN UP a new user
  # POST /auth/signup
  post '/signup' do
    username = @request_payload['username']
    email = @request_payload['email']
    password = @request_payload['password']

    if username.nil? || email.nil? || password.nil?
      halt 400, json({ error: 'Username, email, and password are required' })
    end

    # Check if a user with that email already exists
    existing_user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)
    if existing_user
      halt 409, json({ error: 'User with this email already exists' })
    end

    # Hash the password for secure storage
    password_digest = BCrypt::Password.create(password)

    DB.execute(
      "INSERT INTO users (username, email, password_digest) VALUES (?, ?, ?)",
      username,
      email,
      password_digest
    )

    status 201
    json({ message: 'User created successfully' })
  end

  # LOGIN an existing user
  # POST /auth/login
  post '/login' do
    email = @request_payload['email']
    password = @request_payload['password']

    if email.nil? || password.nil?
      halt 400, json({ error: 'Email and password are required' })
    end

    user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)

    # Verify user exists and password is correct
    if user && BCrypt::Password.new(user['password_digest']) == password
      session[:user_id] = user['id'] # Create the session
      json({ message: 'Logged in successfully', user: { id: user['id'], username: user['username'], email: user['email'] } })
    else
      halt 401, json({ error: 'Invalid email or password' })
    end
  end

  # LOGOUT the current user
  # POST /auth/logout
  post '/logout' do
    session.clear
    json({ message: 'Logged out successfully' })
  end

  # Check the current user's session status
  # GET /auth/profile
  get '/profile' do
    if logged_in?
      json({ logged_in: true, user: current_user })
    else
      json({ logged_in: false })
    end
  end
end
````

## File: backend.md
````markdown
This file is a merged representation of a subset of the codebase, containing files not matching ignore patterns, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching these patterns are excluded: node_modules
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
.gitignore
app/controllers/application_controller.rb
app/controllers/auth_controller.rb
app/controllers/dashboard_controller.rb
app/controllers/feedback_controller.rb
app/controllers/leaderboard_controller.rb
app/controllers/quests_controller.rb
config.ru
db/connection.rb
db/schema.sql
db/seeds.sql
Gemfile
Rakefile
spec/controllers/auth_controller_spec.rb
spec/controllers/dashboard_controller_spec.rb
spec/controllers/feedback_controller_spec.rb
spec/controllers/leaderboard_controller_spec.rb
spec/controllers/protected_routes_spec.rb
spec/controllers/quests_controller_spec.rb
spec/spec_helper.rb
```

# Files

## File: app/controllers/auth_controller.rb
```ruby
require 'sinatra/json'
require 'bcrypt'
require_relative './application_controller'

class AuthController < ApplicationController
  # SIGN UP a new user
  # POST /auth/signup
  post '/signup' do
    username = @request_payload['username']
    email = @request_payload['email']
    password = @request_payload['password']

    if username.nil? || email.nil? || password.nil?
      halt 400, json({ error: 'Username, email, and password are required' })
    end

    # Check if a user with that email already exists
    existing_user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)
    if existing_user
      halt 409, json({ error: 'User with this email already exists' })
    end

    # Hash the password for secure storage
    password_digest = BCrypt::Password.create(password)

    DB.execute(
      "INSERT INTO users (username, email, password_digest) VALUES (?, ?, ?)",
      username,
      email,
      password_digest
    )

    status 201
    json({ message: 'User created successfully' })
  end

  # LOGIN an existing user
  # POST /auth/login
  post '/login' do
    email = @request_payload['email']
    password = @request_payload['password']

    if email.nil? || password.nil?
      halt 400, json({ error: 'Email and password are required' })
    end

    user = DB.get_first_row("SELECT * FROM users WHERE email = ?", email)

    # Verify user exists and password is correct
    if user && BCrypt::Password.new(user['password_digest']) == password
      session[:user_id] = user['id'] # Create the session
      json({ message: 'Logged in successfully', user: { id: user['id'], username: user['username'], email: user['email'] } })
    else
      halt 401, json({ error: 'Invalid email or password' })
    end
  end

  # LOGOUT the current user
  # POST /auth/logout
  post '/logout' do
    session.clear
    json({ message: 'Logged out successfully' })
  end

  # Check the current user's session status
  # GET /auth/profile
  get '/profile' do
    if logged_in?
      json({ logged_in: true, user: current_user })
    else
      json({ logged_in: false })
    end
  end
end
```

## File: spec/controllers/auth_controller_spec.rb
```ruby
# spec/controllers/auth_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Authentication API", type: :request do
  let(:valid_signup_params) { { username: 'New User', email: 'new@example.com', password: 'password123' } }
  let(:valid_login_params) { { email: 'test@example.com', password: 'password123' } }

  # FIX: This block runs before each test in this file to ensure a clean state
  # for the user being created or deleted.
  before(:each) do
    DB.execute("DELETE FROM users WHERE email = ?", 'new@example.com')
  end

  describe 'POST /auth/signup' do
    context 'with valid parameters' do
      it 'creates a new user and returns a success message' do
        post '/auth/signup', valid_signup_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(201)
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('User created successfully')
      end
    end

    context 'with a duplicate email' do
      it 'returns a 409 conflict error' do
        # First, create the user that we expect to conflict with
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        
        # Now, try to create it again
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(409)
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to eq('User with this email already exists')
      end
    end
  end

  describe 'POST /auth/login' do
    context 'with valid credentials' do
      it 'logs the user in and creates a session' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Set-Cookie']).to include('rack.session')
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('Logged in successfully')
      end
    end
  end

  describe 'GET /auth/profile' do
    context 'when user is logged in' do
      it 'returns the current user information' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be true
        expect(json_response['user']['id']).to eq(1)
      end
    end

    context 'when user is not logged in' do
      it 'returns a logged_in: false status' do
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be false
      end
    end
  end

  describe 'POST /auth/logout' do
    it 'clears the session and logs the user out' do
      # First, log in to establish a session
      post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
      
      # Then, log out
      post '/auth/logout'
      expect(last_response.status).to eq(200)
      
      # FIX: Instead of checking the cookie, verify the *effect* of logging out.
      # A subsequent request to a protected endpoint should fail.
      get '/auth/profile'
      json_response = JSON.parse(last_response.body)
      expect(json_response['logged_in']).to be false
    end
  end
end
```

## File: spec/controllers/dashboard_controller_spec.rb
```ruby
# spec/controllers/dashboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Dashboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /dashboard' do
    it 'returns a JSON object with all dashboard components' do
      get '/dashboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response.keys).to contain_exactly(
        'agendaItems', 'activityStream', 'meetings', 'teamEngagement', 'personalEngagement'
      )
    end
  end
end
```

## File: spec/controllers/feedback_controller_spec.rb
```ruby
# spec/controllers/feedback_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Feedback API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /feedback' do
    it 'returns the first page of feedback for the current user' do
      get '/feedback', { page: 1, limit: 2 }
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response['items']).to be_an(Array)
      expect(json_response['items'].first['user_id']).to eq(1)
    end

    it 'correctly reports hasMore when there are more pages' do
      DB.execute("INSERT INTO feedback_history (user_id, subject, content) VALUES (?, ?, ?)", 1, 'Test Subject 2', 'Test Content 2')
      
      get '/feedback', { page: 1, limit: 1 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be true
    end

    it 'correctly reports !hasMore on the last page' do
      get '/feedback', { page: 2, limit: 2 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be false
    end
  end
end
```

## File: spec/controllers/leaderboard_controller_spec.rb
```ruby
# spec/controllers/leaderboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Leaderboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /leaderboard' do
    it 'returns the leaderboard sorted by points descending' do
      get '/leaderboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      points = json_response.map { |entry| entry['points'] }
      expect(points).to eq(points.sort.reverse)
    end

    it 'converts the "badges" field from a string to an array' do
      get '/leaderboard'
      json_response = JSON.parse(last_response.body)
      expect(json_response.first['badges']).to be_an(Array)
    end
  end
end
```

## File: spec/controllers/protected_routes_spec.rb
```ruby
# spec/controllers/protected_routes_spec.rb
# This file tests all controllers that have the `protected!` before filter.

require_relative '../spec_helper'

PROTECTED_ROUTES = {
  'Dashboard'   => '/dashboard',
  'Feedback'    => '/feedback',
  'Leaderboard' => '/leaderboard',
  'Quests'      => '/quests'
}.freeze

PROTECTED_ROUTES.each do |name, path|
  RSpec.describe "#{name} API (Protected)", type: :request do
    describe "GET #{path}" do
      context "when user is not authenticated" do
        it "returns a 401 Unauthorized error" do
          get path
          expect(last_response.status).to eq(401)
          json_response = JSON.parse(last_response.body)
          expect(json_response['error']).to eq('Unauthorized')
        end
      end

      context "when user is authenticated" do
        it "returns a 200 OK status" do
          post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
          get path
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
```

## File: spec/controllers/quests_controller_spec.rb
```ruby
# spec/controllers/quests_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Quests API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /quests' do
    it 'returns a list of quests' do
      get '/quests'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to be > 0
    end

    it 'converts the "completed" field to a boolean' do
      get '/quests'
      json_response = JSON.parse(last_response.body)
      
      completed_quest = json_response.find { |q| q['title'] == 'Adaptability Ace' }
      incomplete_quest = json_response.find { |q| q['title'] == 'Leadership Leap' }
      
      expect(completed_quest['completed']).to be true
      expect(incomplete_quest['completed']).to be false
    end
  end
end
```

## File: spec/spec_helper.rb
```ruby
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
```

## File: .gitignore
```
/vendor/
/.bundle/
/*.sqlite3
*.sqlite3
```

## File: db/connection.rb
```ruby
require 'sqlite3'

# Create a new SQLite3 database file in the db directory
DB = SQLite3::Database.new "db/development.sqlite3"

# Return results as hashes (so we can access columns by name)
DB.results_as_hash = true

# NEW: Wait up to 1 second (1000ms) if the database is locked
# before throwing an exception.
DB.busy_timeout = 1000
```

## File: db/schema.sql
```sql
-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS feedback_history;
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS agenda_items;
DROP TABLE IF EXISTS activity_stream;
DROP TABLE IF EXISTS meetings;

-- Create the users table for authentication
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_digest TEXT NOT NULL
);

-- Create the quests table
CREATE TABLE quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    points INTEGER,
    progress INTEGER,
    completed INTEGER DEFAULT 0 -- Using 0 for false, 1 for true
);

-- Create the feedback_history table
CREATE TABLE feedback_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER, -- Link to the user who submitted it
    subject TEXT,
    content TEXT,
    created_at TEXT, -- Storing date as text in YYYY-MM-DD format
    sentiment TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create the leaderboard table
CREATE TABLE leaderboard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    points INTEGER,
    badges TEXT -- Storing badges as a comma-separated string
);

-- Create agenda_items table for the dashboard
CREATE TABLE agenda_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT, -- 'article' or 'meeting'
    title TEXT,
    category TEXT,
    due_date TEXT
);

-- Create activity_stream table for the dashboard
CREATE TABLE activity_stream (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_name TEXT,
    action TEXT,
    created_at TEXT
);

-- Create meetings table for the dashboard
CREATE TABLE meetings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    meeting_date TEXT,
    status TEXT -- 'Upcoming' or 'Complete'
);
```

## File: db/seeds.sql
```sql
-- =============================================================================
-- File: db/seeds.sql (Updated)
-- =============================================================================
-- This file now includes seed data for the new 'users' table and links
-- the 'feedback_history' entries to these users.

-- Clear existing data from all tables to prevent duplicates on re-seed
DELETE FROM users;
DELETE FROM quests;
DELETE FROM feedback_history;
DELETE FROM leaderboard;
DELETE FROM agenda_items;
DELETE FROM activity_stream;
DELETE FROM meetings;

-- Reset the auto-increment counters for SQLite
DELETE FROM sqlite_sequence;


-- Seed data for the users table
-- Passwords are 'password123' for all users.
-- The actual password digests will be generated by the AuthController when you
-- sign up a real user. These are just placeholders for seeding.
-- INSERT INTO users (id, username, email, password_digest) VALUES
-- (1, 'Alex Rivera', 'alex@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ'),
-- (2, 'Casey Jordan', 'casey@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ'),
-- (3, 'Taylor Morgan', 'taylor@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ');


-- Seed data for the quests table
INSERT INTO quests (title, description, points, progress, completed) VALUES
('Adaptability Ace', 'Complete the "Handling Change" module and score 90% on the quiz.', 150, 100, 1),
('Communication Pro', 'Provide constructive feedback on 5 different project documents.', 200, 60, 0),
('Leadership Leap', 'Lead a project planning session and submit the meeting notes.', 250, 0, 0),
('Teamwork Titan', 'Successfully complete a paired programming challenge.', 100, 100, 1);

-- Seed data for the feedback_history table, now linked to users
INSERT INTO feedback_history (user_id, subject, content, created_at, sentiment) VALUES
(1, 'Q3 Marketing Plan', 'The plan is well-structured, but the timeline seems a bit too aggressive. Consider adding a buffer week.', '2025-08-15', 'Neutral'),
(2, 'New Feature Design', 'I love the new UI! It''s much more intuitive than the previous version. Great work!', '2025-08-14', 'Positive'),
(3, 'API Documentation', 'The endpoint for user authentication is missing examples. It was difficult to understand the required request body.', '2025-08-12', 'Negative');

-- Seed data for the leaderboard table
-- Note: The names here are intentionally the same as the users for consistency.
INSERT INTO leaderboard (name, points, badges) VALUES
('Alex Rivera', 4250, '🚀,🎯,🔥'),
('Casey Jordan', 3980, '💡,🎯'),
('Taylor Morgan', 3710, '🤝');

-- Seed data for the dashboard components
INSERT INTO agenda_items (type, title, category, due_date) VALUES
('article', 'The Art of Giving Constructive Feedback', 'Communication', '2025-08-18'),
('meeting', 'Q3 Project Kickoff', 'Planning', '2025-08-19'),
('article', 'Leading Without Authority', 'Leadership', '2025-08-20');

INSERT INTO activity_stream (user_name, action, created_at) VALUES
('Casey Jordan', 'completed the quest "Teamwork Titan".', '5m ago'),
('Alex Rivera', 'provided feedback on the "Q3 Marketing Plan".', '2h ago'),
('Taylor Morgan', 'updated the status of task "Deploy Staging Server".', '1d ago');

INSERT INTO meetings (title, meeting_date, status) VALUES
('Q3 Project Kickoff', '2025-08-19', 'Upcoming'),
('Weekly Sync: Sprint 14', '2025-08-12', 'Complete'),
('Design Review: New Feature', '2025-08-11', 'Complete');
```

## File: Rakefile
```
## File: Rakefile

require 'sqlite3'
require_relative './db/connection'

namespace :db do
  desc "Setup the database: create, load schema, and seed"
  task :setup do
    puts "Creating database file..."
    DB
    
    puts "Loading schema..."
    Rake::Task['db:schema'].invoke

    puts "Seeding data..."
    Rake::Task['db:seed'].invoke
    
    puts "Database setup complete."
  end

  desc "Load the database schema"
  task :schema do
    sql = File.read('db/schema.sql')
    DB.execute_batch(sql)
    puts "Schema loaded."
  end

  desc "Seed the database with initial data"
  task :seed do
    sql = File.read('db/seeds.sql')
    DB.execute_batch(sql)
    puts "Data seeded."
  end
end
```

## File: app/controllers/application_controller.rb
```ruby
# app/controllers/application_controller.rb

require 'sinatra/base'
require 'sinatra/json'

class ApplicationController < Sinatra::Base
  # --- Global 500 Error Handler ---
  error do
    puts "ERROR: #{env['sinatra.error'].message}"
    puts env['sinatra.error'].backtrace.join("\n")
    status 500
    json({ error: 'An internal server error occurred.' })
  end

  # --- Specific Handler for Database Busy Errors ---
  error SQLite3::BusyException do
    status 503 # Service Unavailable
    json({ error: 'The database is currently busy. Please try again in a moment.' })
  end

  # --- Global 404 Not Found Handler ---
  not_found do
    status 404
    json({ error: 'Not Found' })
  end

  helpers do
    def current_user
      return @current_user if @current_user
      return nil unless session[:user_id]
      @current_user = DB.get_first_row("SELECT id, username, email FROM users WHERE id = ?", session[:user_id])
    end

    def logged_in?
      !current_user.nil?
    end

    def protected!
      halt 401, json({ error: 'Unauthorized' }) unless logged_in?
    end
  end

  # --- JSON Body Parser ---
  before do
    @request_payload = {}
    
    # FINAL FIX: The most robust method. Read the body. If the resulting
    # string is empty, do nothing. Otherwise, parse it. This works
    # in both test and live environments without causing errors.
    body = request.body.read
    
    unless body.empty?
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end
end
```

## File: app/controllers/dashboard_controller.rb
```ruby
require 'sinatra/json'
require_relative './application_controller'

class DashboardController < ApplicationController
  before do
    protected!
  end

  get '/' do
    # Standard data fetches
    agenda_items = DB.execute("SELECT * FROM agenda_items ORDER BY due_date ASC")
    activity_stream = DB.execute("SELECT * FROM activity_stream ORDER BY id DESC LIMIT 5")
    meetings = DB.execute("SELECT * FROM meetings ORDER BY meeting_date DESC")

    # A single, structured mock object for all activity stats
    mock_activity_data = {
      personal: {
        quests:   { allTime: 5, thisWeek: 1 },
        feedback: { allTime: 8, thisWeek: 3 },
        points:   { allTime: 1250, thisWeek: 75 },
        streak:   14 # MODIFIED: Simplified to a single, logical value
      },
      team: {
        quests:   { allTime: 256, thisWeek: 12 },
        feedback: { allTime: 891, thisWeek: 34 },
      }
    }

    # --- Final JSON Response ---
    json({
      agendaItems: agenda_items,
      activityStream: activity_stream,
      meetings: meetings,
      activityData: mock_activity_data
    })
  end
end
```

## File: app/controllers/feedback_controller.rb
```ruby
require 'sinatra/json'
require_relative './application_controller'

class FeedbackController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i
    offset = (page - 1) * limit
    
    # Get the ID of the currently logged-in user
    user_id = current_user['id']

    # Fetch the total count of feedback items ONLY for this user
    total_count = DB.get_first_value("SELECT COUNT(*) FROM feedback_history WHERE user_id = ?", user_id)
    
    # Fetch the paginated feedback items ONLY for this user
    query = "SELECT * FROM feedback_history WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?"
    items_for_page = DB.execute(query, user_id, limit, offset)
    
    has_more = total_count > (offset + items_for_page.length)
    
    json({ items: items_for_page, hasMore: has_more })
  end
end
```

## File: app/controllers/quests_controller.rb
```ruby
require 'sinatra/json'
require_relative './application_controller'

class QuestsController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    result = DB.execute("SELECT * FROM quests ORDER BY id ASC")
    quests = result.map do |row|
      # Convert integer (0 or 1) to boolean for the frontend
      row['completed'] = row['completed'] == 1
      row
    end
    json quests
  end
end
```

## File: app/controllers/leaderboard_controller.rb
```ruby
require 'sinatra/json'
require_relative './application_controller'

class LeaderboardController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    result = DB.execute("SELECT * FROM leaderboard ORDER BY points DESC")
    leaderboard = result.map do |row|
      row['badges'] = row['badges'] ? row['badges'].split(',') : []
      row
    end
    json leaderboard
  end
end
```

## File: config.ru
```
require 'rack/cors'
require_relative './db/connection'

# Require all controllers
require_relative './app/controllers/application_controller'
require_relative './app/controllers/auth_controller'
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

use Rack::Cors do
  allow do
    # This is configured to allow requests from your frontend and Postman.
    # The `credentials: true` part is crucial for session cookies to work.
    origins 'http://localhost:3000' 
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

# Enable and configure cookie-based sessions for all controllers
use Rack::Session::Cookie, {
  key: 'rack.session',
  path: '/',
  expire_after: 2592000, # 30 days in seconds
  # This secret should be kept private in a real application
  secret: '9a78e4f5a3e8c9a3b2b1d0e8c7f9a2b5e4f3a2b1d0c9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1'
}

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/quests') { run QuestsController }
  map('/feedback') { run FeedbackController }
  map('/leaderboard') { run LeaderboardController }
  map('/dashboard') { run DashboardController }
}
```

## File: Gemfile
```
source 'https://rubygems.org'

gem "sinatra"
gem 'puma'
gem 'rackup'
gem 'rerun'

gem 'rack-cors'
gem 'sinatra-contrib'

gem 'sqlite3', '1.6.9'
gem 'bcrypt'

gem 'rake'

group :test do
  gem 'rspec'
  gem 'rack-test'
end
```
````

## File: spec/controllers/auth_controller_spec.rb
````ruby
# spec/controllers/auth_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Authentication API", type: :request do
  let(:valid_signup_params) { { username: 'New User', email: 'new@example.com', password: 'password123' } }
  let(:valid_login_params) { { email: 'test@example.com', password: 'password123' } }

  # FIX: This block runs before each test in this file to ensure a clean state
  # for the user being created or deleted.
  before(:each) do
    DB.execute("DELETE FROM users WHERE email = ?", 'new@example.com')
  end

  describe 'POST /auth/signup' do
    context 'with valid parameters' do
      it 'creates a new user and returns a success message' do
        post '/auth/signup', valid_signup_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(201)
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('User created successfully')
      end
    end

    context 'with a duplicate email' do
      it 'returns a 409 conflict error' do
        # First, create the user that we expect to conflict with
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        
        # Now, try to create it again
        post '/auth/signup', { username: 'Another User', email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(409)
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to eq('User with this email already exists')
      end
    end
  end

  describe 'POST /auth/login' do
    context 'with valid credentials' do
      it 'logs the user in and creates a session' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Set-Cookie']).to include('rack.session')
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq('Logged in successfully')
      end
    end
  end

  describe 'GET /auth/profile' do
    context 'when user is logged in' do
      it 'returns the current user information' do
        post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be true
        expect(json_response['user']['id']).to eq(1)
      end
    end

    context 'when user is not logged in' do
      it 'returns a logged_in: false status' do
        get '/auth/profile'
        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response['logged_in']).to be false
      end
    end
  end

  describe 'POST /auth/logout' do
    it 'clears the session and logs the user out' do
      # First, log in to establish a session
      post '/auth/login', valid_login_params.to_json, 'CONTENT_TYPE' => 'application/json'
      
      # Then, log out
      post '/auth/logout'
      expect(last_response.status).to eq(200)
      
      # FIX: Instead of checking the cookie, verify the *effect* of logging out.
      # A subsequent request to a protected endpoint should fail.
      get '/auth/profile'
      json_response = JSON.parse(last_response.body)
      expect(json_response['logged_in']).to be false
    end
  end
end
````

## File: spec/controllers/dashboard_controller_spec.rb
````ruby
# spec/controllers/dashboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Dashboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /dashboard' do
    it 'returns a JSON object with all dashboard components' do
      get '/dashboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response.keys).to contain_exactly(
        'agendaItems', 'activityStream', 'meetings', 'teamEngagement', 'personalEngagement'
      )
    end
  end
end
````

## File: spec/controllers/feedback_controller_spec.rb
````ruby
# spec/controllers/feedback_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Feedback API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /feedback' do
    it 'returns the first page of feedback for the current user' do
      get '/feedback', { page: 1, limit: 2 }
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      expect(json_response['items']).to be_an(Array)
      expect(json_response['items'].first['user_id']).to eq(1)
    end

    it 'correctly reports hasMore when there are more pages' do
      DB.execute("INSERT INTO feedback_history (user_id, subject, content) VALUES (?, ?, ?)", 1, 'Test Subject 2', 'Test Content 2')
      
      get '/feedback', { page: 1, limit: 1 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be true
    end

    it 'correctly reports !hasMore on the last page' do
      get '/feedback', { page: 2, limit: 2 }
      json_response = JSON.parse(last_response.body)
      expect(json_response['hasMore']).to be false
    end
  end
end
````

## File: spec/controllers/leaderboard_controller_spec.rb
````ruby
# spec/controllers/leaderboard_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Leaderboard API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /leaderboard' do
    it 'returns the leaderboard sorted by points descending' do
      get '/leaderboard'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      
      points = json_response.map { |entry| entry['points'] }
      expect(points).to eq(points.sort.reverse)
    end

    it 'converts the "badges" field from a string to an array' do
      get '/leaderboard'
      json_response = JSON.parse(last_response.body)
      expect(json_response.first['badges']).to be_an(Array)
    end
  end
end
````

## File: spec/controllers/protected_routes_spec.rb
````ruby
# spec/controllers/protected_routes_spec.rb
# This file tests all controllers that have the `protected!` before filter.

require_relative '../spec_helper'

PROTECTED_ROUTES = {
  'Dashboard'   => '/dashboard',
  'Feedback'    => '/feedback',
  'Leaderboard' => '/leaderboard',
  'Quests'      => '/quests'
}.freeze

PROTECTED_ROUTES.each do |name, path|
  RSpec.describe "#{name} API (Protected)", type: :request do
    describe "GET #{path}" do
      context "when user is not authenticated" do
        it "returns a 401 Unauthorized error" do
          get path
          expect(last_response.status).to eq(401)
          json_response = JSON.parse(last_response.body)
          expect(json_response['error']).to eq('Unauthorized')
        end
      end

      context "when user is authenticated" do
        it "returns a 200 OK status" do
          post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
          get path
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
````

## File: spec/controllers/quests_controller_spec.rb
````ruby
# spec/controllers/quests_controller_spec.rb

require_relative '../spec_helper'

RSpec.describe "Quests API", type: :request do
  before do
    post '/auth/login', { email: 'test@example.com', password: 'password123' }.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /quests' do
    it 'returns a list of quests' do
      get '/quests'
      expect(last_response.status).to eq(200)
      json_response = JSON.parse(last_response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to be > 0
    end

    it 'converts the "completed" field to a boolean' do
      get '/quests'
      json_response = JSON.parse(last_response.body)
      
      completed_quest = json_response.find { |q| q['title'] == 'Adaptability Ace' }
      incomplete_quest = json_response.find { |q| q['title'] == 'Leadership Leap' }
      
      expect(completed_quest['completed']).to be true
      expect(incomplete_quest['completed']).to be false
    end
  end
end
````

## File: spec/spec_helper.rb
````ruby
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
````

## File: .gitignore
````
/vendor/
/.bundle/
/*.sqlite3
*.sqlite3
````

## File: db/connection.rb
````ruby
require 'sqlite3'

# Create a new SQLite3 database file in the db directory
DB = SQLite3::Database.new "db/development.sqlite3"

# Return results as hashes (so we can access columns by name)
DB.results_as_hash = true

# NEW: Wait up to 1 second (1000ms) if the database is locked
# before throwing an exception.
DB.busy_timeout = 1000
````

## File: db/schema.sql
````sql
-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS feedback_history;
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS agenda_items;
DROP TABLE IF EXISTS activity_stream;
DROP TABLE IF EXISTS meetings;

-- Create the users table for authentication
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_digest TEXT NOT NULL
);

-- Create the quests table
CREATE TABLE quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    points INTEGER,
    progress INTEGER,
    completed INTEGER DEFAULT 0 -- Using 0 for false, 1 for true
);

-- Create the feedback_history table
CREATE TABLE feedback_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER, -- Link to the user who submitted it
    subject TEXT,
    content TEXT,
    created_at TEXT, -- Storing date as text in YYYY-MM-DD format
    sentiment TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create the leaderboard table
CREATE TABLE leaderboard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    points INTEGER,
    badges TEXT -- Storing badges as a comma-separated string
);

-- Create agenda_items table for the dashboard
CREATE TABLE agenda_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT, -- 'article' or 'meeting'
    title TEXT,
    category TEXT,
    due_date TEXT
);

-- Create activity_stream table for the dashboard
CREATE TABLE activity_stream (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_name TEXT,
    action TEXT,
    created_at TEXT
);

-- Create meetings table for the dashboard
CREATE TABLE meetings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    meeting_date TEXT,
    status TEXT -- 'Upcoming' or 'Complete'
);
````

## File: db/seeds.sql
````sql
-- =============================================================================
-- File: db/seeds.sql (Updated)
-- =============================================================================
-- This file now includes seed data for the new 'users' table and links
-- the 'feedback_history' entries to these users.

-- Clear existing data from all tables to prevent duplicates on re-seed
DELETE FROM users;
DELETE FROM quests;
DELETE FROM feedback_history;
DELETE FROM leaderboard;
DELETE FROM agenda_items;
DELETE FROM activity_stream;
DELETE FROM meetings;

-- Reset the auto-increment counters for SQLite
DELETE FROM sqlite_sequence;


-- Seed data for the users table
-- Passwords are 'password123' for all users.
-- The actual password digests will be generated by the AuthController when you
-- sign up a real user. These are just placeholders for seeding.
-- INSERT INTO users (id, username, email, password_digest) VALUES
-- (1, 'Alex Rivera', 'alex@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ'),
-- (2, 'Casey Jordan', 'casey@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ'),
-- (3, 'Taylor Morgan', 'taylor@example.com', '$2a$12$s.U/0g.4y.9bJgY.1/2g.Ou/1g.4y.9bJgY.1/2g.Ou/1g.4y.9bJ');


-- Seed data for the quests table
INSERT INTO quests (title, description, points, progress, completed) VALUES
('Adaptability Ace', 'Complete the "Handling Change" module and score 90% on the quiz.', 150, 100, 1),
('Communication Pro', 'Provide constructive feedback on 5 different project documents.', 200, 60, 0),
('Leadership Leap', 'Lead a project planning session and submit the meeting notes.', 250, 0, 0),
('Teamwork Titan', 'Successfully complete a paired programming challenge.', 100, 100, 1);

-- Seed data for the feedback_history table, now linked to users
INSERT INTO feedback_history (user_id, subject, content, created_at, sentiment) VALUES
(1, 'Q3 Marketing Plan', 'The plan is well-structured, but the timeline seems a bit too aggressive. Consider adding a buffer week.', '2025-08-15', 'Neutral'),
(2, 'New Feature Design', 'I love the new UI! It''s much more intuitive than the previous version. Great work!', '2025-08-14', 'Positive'),
(3, 'API Documentation', 'The endpoint for user authentication is missing examples. It was difficult to understand the required request body.', '2025-08-12', 'Negative');

-- Seed data for the leaderboard table
-- Note: The names here are intentionally the same as the users for consistency.
INSERT INTO leaderboard (name, points, badges) VALUES
('Alex Rivera', 4250, '🚀,🎯,🔥'),
('Casey Jordan', 3980, '💡,🎯'),
('Taylor Morgan', 3710, '🤝');

-- Seed data for the dashboard components
INSERT INTO agenda_items (type, title, category, due_date) VALUES
('article', 'The Art of Giving Constructive Feedback', 'Communication', '2025-08-18'),
('meeting', 'Q3 Project Kickoff', 'Planning', '2025-08-19'),
('article', 'Leading Without Authority', 'Leadership', '2025-08-20');

INSERT INTO activity_stream (user_name, action, created_at) VALUES
('Casey Jordan', 'completed the quest "Teamwork Titan".', '5m ago'),
('Alex Rivera', 'provided feedback on the "Q3 Marketing Plan".', '2h ago'),
('Taylor Morgan', 'updated the status of task "Deploy Staging Server".', '1d ago');

INSERT INTO meetings (title, meeting_date, status) VALUES
('Q3 Project Kickoff', '2025-08-19', 'Upcoming'),
('Weekly Sync: Sprint 14', '2025-08-12', 'Complete'),
('Design Review: New Feature', '2025-08-11', 'Complete');
````

## File: Rakefile
````
## File: Rakefile

require 'sqlite3'
require_relative './db/connection'

namespace :db do
  desc "Setup the database: create, load schema, and seed"
  task :setup do
    puts "Creating database file..."
    DB
    
    puts "Loading schema..."
    Rake::Task['db:schema'].invoke

    puts "Seeding data..."
    Rake::Task['db:seed'].invoke
    
    puts "Database setup complete."
  end

  desc "Load the database schema"
  task :schema do
    sql = File.read('db/schema.sql')
    DB.execute_batch(sql)
    puts "Schema loaded."
  end

  desc "Seed the database with initial data"
  task :seed do
    sql = File.read('db/seeds.sql')
    DB.execute_batch(sql)
    puts "Data seeded."
  end
end
````

## File: app/controllers/application_controller.rb
````ruby
# app/controllers/application_controller.rb

require 'sinatra/base'
require 'sinatra/json'

class ApplicationController < Sinatra::Base
  # --- Global 500 Error Handler ---
  error do
    puts "ERROR: #{env['sinatra.error'].message}"
    puts env['sinatra.error'].backtrace.join("\n")
    status 500
    json({ error: 'An internal server error occurred.' })
  end

  # --- Specific Handler for Database Busy Errors ---
  error SQLite3::BusyException do
    status 503 # Service Unavailable
    json({ error: 'The database is currently busy. Please try again in a moment.' })
  end

  # --- Global 404 Not Found Handler ---
  not_found do
    status 404
    json({ error: 'Not Found' })
  end

  helpers do
    def current_user
      return @current_user if @current_user
      return nil unless session[:user_id]
      @current_user = DB.get_first_row("SELECT id, username, email FROM users WHERE id = ?", session[:user_id])
    end

    def logged_in?
      !current_user.nil?
    end

    def protected!
      halt 401, json({ error: 'Unauthorized' }) unless logged_in?
    end
  end

  # --- JSON Body Parser ---
  before do
    @request_payload = {}
    
    # FINAL FIX: The most robust method. Read the body. If the resulting
    # string is empty, do nothing. Otherwise, parse it. This works
    # in both test and live environments without causing errors.
    body = request.body.read
    
    unless body.empty?
      begin
        @request_payload = JSON.parse(body)
      rescue JSON::ParserError
        halt 400, json({ error: 'Invalid JSON in request body' })
      end
    end
  end
end
````

## File: app/controllers/dashboard_controller.rb
````ruby
require 'sinatra/json'
require_relative './application_controller'

class DashboardController < ApplicationController
  before do
    protected!
  end

  get '/' do
    # Standard data fetches
    agenda_items = DB.execute("SELECT * FROM agenda_items ORDER BY due_date ASC")
    activity_stream = DB.execute("SELECT * FROM activity_stream ORDER BY id DESC LIMIT 5")
    meetings = DB.execute("SELECT * FROM meetings ORDER BY meeting_date DESC")

    # A single, structured mock object for all activity stats
    mock_activity_data = {
      personal: {
        quests:   { allTime: 5, thisWeek: 1 },
        feedback: { allTime: 8, thisWeek: 3 },
        points:   { allTime: 1250, thisWeek: 75 },
        streak:   14 # MODIFIED: Simplified to a single, logical value
      },
      team: {
        quests:   { allTime: 256, thisWeek: 12 },
        feedback: { allTime: 891, thisWeek: 34 },
      }
    }

    # --- Final JSON Response ---
    json({
      agendaItems: agenda_items,
      activityStream: activity_stream,
      meetings: meetings,
      activityData: mock_activity_data
    })
  end
end
````

## File: app/controllers/feedback_controller.rb
````ruby
require 'sinatra/json'
require_relative './application_controller'

class FeedbackController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i
    offset = (page - 1) * limit
    
    # Get the ID of the currently logged-in user
    user_id = current_user['id']

    # Fetch the total count of feedback items ONLY for this user
    total_count = DB.get_first_value("SELECT COUNT(*) FROM feedback_history WHERE user_id = ?", user_id)
    
    # Fetch the paginated feedback items ONLY for this user
    query = "SELECT * FROM feedback_history WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?"
    items_for_page = DB.execute(query, user_id, limit, offset)
    
    has_more = total_count > (offset + items_for_page.length)
    
    json({ items: items_for_page, hasMore: has_more })
  end
end
````

## File: app/controllers/quests_controller.rb
````ruby
require 'sinatra/json'
require_relative './application_controller'

class QuestsController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    result = DB.execute("SELECT * FROM quests ORDER BY id ASC")
    quests = result.map do |row|
      # Convert integer (0 or 1) to boolean for the frontend
      row['completed'] = row['completed'] == 1
      row
    end
    json quests
  end
end
````

## File: app/controllers/leaderboard_controller.rb
````ruby
require 'sinatra/json'
require_relative './application_controller'

class LeaderboardController < ApplicationController
  before do
    protected!
  end
  
  get '/' do
    result = DB.execute("SELECT * FROM leaderboard ORDER BY points DESC")
    leaderboard = result.map do |row|
      row['badges'] = row['badges'] ? row['badges'].split(',') : []
      row
    end
    json leaderboard
  end
end
````

## File: config.ru
````
require 'rack/cors'
require_relative './db/connection'

# Require all controllers
require_relative './app/controllers/application_controller'
require_relative './app/controllers/auth_controller'
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

use Rack::Cors do
  allow do
    # This is configured to allow requests from your frontend and Postman.
    # The `credentials: true` part is crucial for session cookies to work.
    origins 'http://localhost:3000' 
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end

# Enable and configure cookie-based sessions for all controllers
use Rack::Session::Cookie, {
  key: 'rack.session',
  path: '/',
  expire_after: 2592000, # 30 days in seconds
  # This secret should be kept private in a real application
  secret: '9a78e4f5a3e8c9a3b2b1d0e8c7f9a2b5e4f3a2b1d0c9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1'
}

run Rack::Builder.new {
  map('/auth') { run AuthController }
  map('/quests') { run QuestsController }
  map('/feedback') { run FeedbackController }
  map('/leaderboard') { run LeaderboardController }
  map('/dashboard') { run DashboardController }
}
````

## File: Gemfile
````
source 'https://rubygems.org'

gem "sinatra"
gem 'puma'
gem 'rackup'
gem 'rerun'

gem 'rack-cors'
gem 'sinatra-contrib'

gem 'sqlite3', '1.6.9'
gem 'bcrypt'

gem 'rake'

group :test do
  gem 'rspec'
  gem 'rack-test'
end
````
