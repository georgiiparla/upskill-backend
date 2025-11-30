class AdminController < ApplicationController
  get '/users' do
    admin_protected!
    
    all_users = User.order(created_at: :desc)
    
    users_json = all_users.map do |user|
      {
        username: user.username,
        email: user.email,
        created_at: user.created_at
      }
    end

    json users_json
  end
end