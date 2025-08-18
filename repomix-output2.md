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
app/controllers/dashboard_controller.rb
app/controllers/feedback_controller.rb
app/controllers/leaderboard_controller.rb
app/controllers/quests_controller.rb
app/controllers/session_draft.rb
config.ru
db/connection.rb
db/schema.sql
db/seed.sql
Gemfile
Rakefile
```

# Files

## File: .gitignore
```
vendor
.bundle
```

## File: app/controllers/dashboard_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class DashboardController < Sinatra::Base
  # Engagement data is complex to calculate, so we'll keep it as mock data.
  # In a real app, this would be the result of an analytics query.
  MOCK_TEAM_ENGAGEMENT_DATA = [
    { category: 'Quests', value: 75, fullMark: 100 },
    { category: 'Feedback', value: 85, fullMark: 100 },
    { category: 'Meetings', value: 90, fullMark: 100 },
    { category: 'Knowledge', value: 60, fullMark: 100 },
    { category: 'Skills', value: 70, fullMark: 100 },
  ]
  MOCK_PERSONAL_ENGAGEMENT_DATA = [
    { category: 'Quests', value: 95, fullMark: 100 },
    { category: 'Feedback', value: 60, fullMark: 100 },
    { category: 'Meetings', value: 100, fullMark: 100 },
    { category: 'Knowledge', value: 80, fullMark: 100 },
    { category: 'Skills', value: 45, fullMark: 100 },
  ]

  get '/' do
    # Fetch all dashboard data from the database in separate queries
    agenda_items = DB.execute("SELECT * FROM agenda_items ORDER BY due_date ASC")
    activity_stream = DB.execute("SELECT * FROM activity_stream ORDER BY id DESC LIMIT 5")
    meetings = DB.execute("SELECT * FROM meetings ORDER BY meeting_date DESC")

    # Respond with a single JSON object containing all the data
    json({
      agendaItems: agenda_items,
      activityStream: activity_stream,
      meetings: meetings,
      teamEngagement: MOCK_TEAM_ENGAGEMENT_DATA,
      personalEngagement: MOCK_PERSONAL_ENGAGEMENT_DATA
    })
  end
end
```

## File: app/controllers/session_draft.rb
```ruby
require 'sinatra/base'

class MainApp < Sinatra::Base
  enable :sessions
  set :session_secret, '9a78e4f5a3e8c9a3b2b1d0e8c7f9a2b5e4f3a2b1d0c9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1'

  get '/' do
    'Hello world! This is the main application.'
  end
  
  get '/about' do
    'This is the about page.'
  end

  get '/remember' do
    session[:message] = "I'm remembering this!"
    'Saved a message to your session.'
  end

  get '/recall' do
    if session[:message]
      "The message from your session is: #{session[:message]}"
    else
      "There is no message in your session."
    end
  end
  
  get '/forget' do
    session.clear
    'Session cleared.'
  end
end
```

## File: db/connection.rb
```ruby
# -----------------------------------------------------------------------------
# File: db/connection.rb (NEW FILE)
# -----------------------------------------------------------------------------
require 'sqlite3'

# Create a new SQLite3 database file in the db directory
DB = SQLite3::Database.new "db/development.sqlite3"

# Return results as hashes (so we can access columns by name)
DB.results_as_hash = true
```

## File: db/schema.sql
```sql
-- Drop tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS quests;
DROP TABLE IF EXISTS feedback_history;
DROP TABLE IF EXISTS leaderboard;
DROP TABLE IF EXISTS agenda_items;
DROP TABLE IF EXISTS activity_stream;
DROP TABLE IF EXISTS meetings;

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
    subject TEXT,
    content TEXT,
    created_at TEXT, -- Storing date as text in YYYY-MM-DD format
    sentiment TEXT
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

## File: db/seed.sql
```sql
-- Seed data for the quests table
INSERT INTO quests (title, description, points, progress, completed) VALUES
('Adaptability Ace', 'Complete the "Handling Change" module and score 90% on the quiz.', 150, 100, 1),
('Communication Pro', 'Provide constructive feedback on 5 different project documents.', 200, 60, 0),
('Leadership Leap', 'Lead a project planning session and submit the meeting notes.', 250, 0, 0),
('Teamwork Titan', 'Successfully complete a paired programming challenge.', 100, 100, 1);

-- Seed data for the feedback_history table
INSERT INTO feedback_history (subject, content, created_at, sentiment) VALUES
('Q3 Marketing Plan', 'The plan is well-structured, but the timeline seems a bit too aggressive. Consider adding a buffer week.', '2025-08-15', 'Neutral'),
('New Feature Design', 'I love the new UI! It''s much more intuitive than the previous version. Great work!', '2025-08-14', 'Positive'),
('API Documentation', 'The endpoint for user authentication is missing examples. It was difficult to understand the required request body.', '2025-08-12', 'Negative');

-- Seed data for the leaderboard table
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
require 'sqlite3'
require_relative './db/connection'

namespace :db do
  desc "Setup the database: create, load schema, and seed"
  task :setup do
    puts "Creating database file..."
    # The connection file itself will create the DB if it doesn't exist
    DB
    
    puts "Loading schema..."
    Rake::Task['db:schema:load'].invoke
    
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

## File: app/controllers/feedback_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class FeedbackController < Sinatra::Base
  get '/' do
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i
    offset = (page - 1) * limit
    total_count = DB.get_first_value("SELECT COUNT(*) FROM feedback_history")
    query = "SELECT * FROM feedback_history ORDER BY created_at DESC LIMIT ? OFFSET ?"
    items_for_page = DB.execute(query, limit, offset)
    has_more = total_count > (offset + items_for_page.length)
    json({ items: items_for_page, hasMore: has_more })
  end
end
```

## File: app/controllers/leaderboard_controller.rb
```ruby
class LeaderboardController < Sinatra::Base
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

## File: app/controllers/quests_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class QuestsController < Sinatra::Base
  get '/' do
    result = DB.execute("SELECT * FROM quests ORDER BY id ASC")
    quests = result.map do |row|
      row['completed'] = row['completed'] == 1
      row
    end
    json quests
  end
end
```

## File: config.ru
```
# -----------------------------------------------------------------------------
# File: config.ru (Updated)
# -----------------------------------------------------------------------------
require 'rack/cors'
require_relative './db/connection' # Require the DB connection

# Require all controllers
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

use Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

run Rack::Builder.new {
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

gem 'rake'
```
