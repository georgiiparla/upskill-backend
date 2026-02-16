class UsersController < ApplicationController
  
  get '/search' do
    protected!
    
    query = params['q']&.strip
    if query.nil? || query.length < 2
        json_error('Query too short', 400)
    end

    # Stateless rate limiting using in-memory cache
    check_search_rate_limit!(current_user.id)

    # Case insensitive search, exclude current user, limit to 5 results
    users = User.where('lower(username) LIKE ?', "%#{query.downcase}%")
                .where.not(id: current_user.id)
                .limit(10)
                .select(:id, :username)

    json users
  end

end
