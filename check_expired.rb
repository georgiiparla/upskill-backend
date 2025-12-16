require './app/controllers/application_controller'

puts "Current Time: #{Time.now}"
puts "---"

pending_count = FeedbackRequest.where(status: 'pending').count
puts "Total Pending Requests: #{pending_count}"

expired_pending = FeedbackRequest.where(status: 'pending').where('expires_at < ?', Time.now)
puts "Expired Pending Requests (Should be closed): #{expired_pending.count}"

expired_pending.each do |req|
  puts " - ID: #{req.id}, Topic: #{req.topic}, Expires: #{req.expires_at}"
end

puts "---"
puts "Job Logic Check:"
puts "It closes requests where status='pending' AND expires_at < NOW."
