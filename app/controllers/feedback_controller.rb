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