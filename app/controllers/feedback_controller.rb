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