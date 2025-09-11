namespace :feedback do
  desc "Close feedback requests that have expired"
  task close_expired: :environment do
    puts "--> Closing expired feedback requests..."
    expired_count = FeedbackRequest.where(status: 'pending').where('expires_at < ?', Time.now).update_all(status: 'closed')
    puts "    Closed #{expired_count} expired request(s)."
    puts "--> Task complete."
  end
end