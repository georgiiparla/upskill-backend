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
Gemfile
```

# Files

## File: app/controllers/dashboard_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class DashboardController < Sinatra::Base
  # --- All the mock data needed for the dashboard page ---

  MOCK_AGENDA_ITEMS = [
    { id: 1, type: 'article', title: 'The Art of Giving Constructive Feedback', category: 'Communication' },
    { id: 2, type: 'meeting', title: 'Q3 Project Kickoff', date: '2025-08-16' },
    { id: 3, type: 'article', title: 'Leading Without Authority', category: 'Leadership' },
  ]

  MOCK_ACTIVITY_STREAM = [
    { id: 1, user: 'Casey Jordan', action: 'completed the quest "Teamwork Titan".', time: '5m ago' },
    { id: 2, user: 'Alex Rivera', action: 'provided feedback on the "Q3 Marketing Plan".', time: '2h ago' },
    { id: 3, user: 'Taylor Morgan', action: 'updated the status of task "Deploy Staging Server".', time: '1d ago' },
    { id: 4, user: 'Jamie Lee', action: 'read the article "Leading Without Authority".', time: '1d ago' },
    { id: 5, user: 'Jordan Smith', action: 'RSVP\'d to "Q3 Project Kickoff".', time: '2d ago' },
  ]

  MOCK_MEETINGS = [
    { id: 1, title: 'Q3 Project Kickoff', date: '2025-08-16', status: 'Upcoming' },
    { id: 2, title: 'Weekly Sync: Sprint 14', date: '2025-08-12', status: 'Complete' },
    { id: 3, title: 'Design Review: New Feature', date: '2025-08-11', status: 'Complete' },
  ]

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

  # GET /dashboard
  # Returns a single JSON object with all data for the dashboard.
  get '/' do
    json({
      agendaItems: MOCK_AGENDA_ITEMS,
      activityStream: MOCK_ACTIVITY_STREAM,
      meetings: MOCK_MEETINGS,
      teamEngagement: MOCK_TEAM_ENGAGEMENT_DATA,
      personalEngagement: MOCK_PERSONAL_ENGAGEMENT_DATA
    })
  end
end
```

## File: .gitignore
```
vendor
.bundle
```

## File: app/controllers/feedback_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class FeedbackController < Sinatra::Base
  # This data structure matches what the frontend expects.
  MOCK_FEEDBACK_HISTORY = [
    { id: 1, subject: 'Q3 Marketing Plan', content: 'The plan is well-structured, but the timeline seems a bit too aggressive. Consider adding a buffer week.', date: '2025-08-15', sentiment: 'Neutral' },
    { id: 2, subject: 'New Feature Design', content: 'I love the new UI! It\'s much more intuitive than the previous version. Great work!', date: '2025-08-14', sentiment: 'Positive' },
    { id: 3, subject: 'API Documentation', content: 'The endpoint for user authentication is missing examples. It was difficult to understand the required request body.', date: '2025-08-12', sentiment: 'Negative' },
    { id: 4, subject: 'Onboarding Process', content: 'The new hire checklist is very helpful, but links to the HR system are broken.', date: '2025-08-11', sentiment: 'Negative' },
    { id: 5, subject: 'Weekly Sync Meeting', content: 'These meetings are productive. The agenda is clear and we stick to the topics. No changes needed.', date: '2025-08-08', sentiment: 'Positive' },
    { id: 6, subject: 'Project Alpha Performance', content: 'The application is running slower this week. We should investigate potential memory leaks.', date: '2025-08-07', sentiment: 'Neutral' },
    { id: 7, subject: 'Team Offsite Event', content: 'The proposed venue looks great and the activities seem fun. I\'m looking forward to it.', date: '2025-08-05', sentiment: 'Positive' },
    { id: 8, subject: 'General Feedback', content: 'The new dark mode is fantastic on the eyes. Thank you for implementing it!', date: '2025-08-04', sentiment: 'Positive' },
    { id: 9, subject: 'Q3 Marketing Plan', content: 'The budget allocation for social media seems low given our goals.', date: '2025-08-02', sentiment: 'Neutral' },
    { id: 10, subject: 'API Documentation', content: 'The rate limiting section is very clear and well-written.', date: '2025-08-01', sentiment: 'Positive' },
    { id: 11, subject: 'New Feature Design', content: 'The placement of the new button feels a bit awkward on mobile devices.', date: '2025-07-30', sentiment: 'Negative' },
    { id: 12, subject: 'Weekly Sync Meeting', content: 'Could we allocate some time at the end of the sync for open Q&A?', date: '2025-07-28', sentiment: 'Neutral' },
  ]

  # GET /feedback?page=1&limit=5
  # Returns a paginated list of feedback items.
  get '/' do
    # Get page and limit from query params, with default values
    page = params.fetch('page', 1).to_i
    limit = params.fetch('limit', 5).to_i
    
    # Calculate the starting index for the slice
    start_index = (page - 1) * limit
    
    # Slice the array to get the items for the current page
    items_for_page = MOCK_FEEDBACK_HISTORY.slice(start_index, limit) || []
    
    # Determine if there are more items on subsequent pages
    has_more = MOCK_FEEDBACK_HISTORY.length > (start_index + items_for_page.length)
    
    # Return a JSON object containing the items and the 'hasMore' flag
    json({
      items: items_for_page,
      hasMore: has_more
    })
  end
end
```

## File: app/controllers/leaderboard_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class LeaderboardController < Sinatra::Base
  # In a real app, this data would come from a database, likely sorted by points.
  MOCK_LEADERBOARD = [
    { id: 1, name: 'Alex Rivera', points: 4250, badges: ['🚀', '🎯', '🔥'] },
    { id: 2, name: 'Casey Jordan', points: 3980, badges: ['💡', '🎯'] },
    { id: 3, name: 'Taylor Morgan', points: 3710, badges: ['🤝'] },
    { id: 4, name: 'Jordan Smith', points: 3500, badges: ['🚀'] },
    { id: 5, name: 'Jamie Lee', points: 3200, badges: ['💡', '🤝'] },
    { id: 6, name: 'Morgan Quinn', points: 2950, badges: ['🎯'] },
    { id: 7, name: 'Riley Chen', points: 2810, badges: ['🔥', '🤝'] },
    { id: 8, name: 'Devin Patel', points: 2650, badges: ['💡'] },
    { id: 9, name: 'Skyler Kim', points: 2400, badges: ['🚀', '🎯'] },
    { id: 10, name: 'Avery Garcia', points: 2230, badges: ['🤝'] },
    { id: 11, name: 'Parker Williams', points: 2100, badges: ['💡'] },
    { id: 12, name: 'Cameron Ito', points: 1980, badges: ['🔥'] },
    { id: 13, name: 'Rowan Davis', points: 1850, badges: ['🚀'] },
    { id: 14, name: 'Kai Martinez', points: 1720, badges: ['🎯', '🤝'] },
    { id: 15, name: 'Logan Rodriguez', points: 1600, badges: ['💡'] },
  ]

  # GET /leaderboard
  # Returns the entire leaderboard list as a JSON array.
  get '/' do
    json MOCK_LEADERBOARD
  end
end
```

## File: app/controllers/quests_controller.rb
```ruby
require 'sinatra/base'
require 'sinatra/json'

class QuestsController < Sinatra::Base
  # Hardcoded quest data that matches the frontend's expected structure.
  # In a real application, this would come from a database.
  MOCK_QUESTS = [
    { id: 1, title: 'Adaptability Ace', description: 'Complete the "Handling Change" module and score 90% on the quiz.', points: 150, progress: 100, completed: true },
    { id: 2, title: 'Communication Pro', description: 'Provide constructive feedback on 5 different project documents.', points: 200, progress: 60, completed: false },
    { id: 3, title: 'Leadership Leap', description: 'Lead a project planning session and submit the meeting notes.', points: 250, progress: 0, completed: false },
    { id: 4, title: 'Teamwork Titan', description: 'Successfully complete a paired programming challenge.', points: 100, progress: 100, completed: true },
  ]

  # GET /quests
  # Returns the list of all quests as a JSON array.
  get '/' do
    # The `json` helper method from sinatra-contrib automatically sets
    # the Content-Type header to application/json and serializes the data.
    json MOCK_QUESTS
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

## File: config.ru
```
require 'rack/cors'

# ... (keep existing requires)
require_relative './app/controllers/quests_controller'
require_relative './app/controllers/feedback_controller'
require_relative './app/controllers/leaderboard_controller'
require_relative './app/controllers/dashboard_controller'

# ... (keep CORS block unchanged)
use Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

run Rack::Builder.new {
  # ... (keep existing maps)
  map '/quests' do
    run QuestsController
  end
  
  # Add this block for the new feedback route
  map '/feedback' do
    run FeedbackController
  end

  map '/dashboard' do
    run DashboardController
  end

  map '/leaderboard' do
    run LeaderboardController
  end
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
```
