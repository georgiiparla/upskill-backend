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