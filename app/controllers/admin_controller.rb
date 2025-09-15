class AdminController < ApplicationController
  get '/users' do
    protected!

    authorized_users = User.order(created_at: :desc).all.select(&:authorized?)
    
    users_json = authorized_users.map do |user|
      {
        id: user.id,
        username: user.username,
        email: user.email,
        created_at: user.created_at
      }
    end

    json users_json
  end
end