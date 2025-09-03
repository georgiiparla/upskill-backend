puts "Seeding database..."

ActiveRecord::Base.transaction do
  puts "   - Deleting old data..."
  [User, Quest, FeedbackHistory, Leaderboard, AgendaItem, ActivityStream, Meeting].each(&:destroy_all)

  puts "   - Creating users..."
  users = {}
  users[:alex]   = User.create!(username: 'Alex Rivera',      email: 'alex@example.com',    password: 'password123')
  users[:casey]  = User.create!(username: 'Casey Jordan',     email: 'casey@example.com',   password: 'password123')
  users[:taylor] = User.create!(username: 'Taylor Morgan',    email: 'taylor@example.com',  password: 'password123')
  users[:jordan] = User.create!(username: 'Jordan Smith',     email: 'jordan@example.com',  password: 'password123')
  users[:jamie]  = User.create!(username: 'Jamie Lee',        email: 'jamie@example.com',   password: 'password123')
  users[:morgan] = User.create!(username: 'Morgan Quinn',     email: 'morgan@example.com',  password: 'password123')

  puts "   - Creating quests..."
  Quest.create!([
    { title: 'Adaptability Ace', description: 'Complete the "Handling Change" module and score 90% on the quiz.', points: 150, progress: 100, completed: true },
    { title: 'Communication Pro', description: 'Provide constructive feedback on 5 different project documents.', points: 200, progress: 60, completed: false },
    { title: 'Leadership Leap', description: 'Lead a project planning session and submit the meeting notes.', points: 250, progress: 0, completed: false },
    { title: 'Teamwork Titan', description: 'Successfully complete a paired programming challenge.', points: 100, progress: 100, completed: true }
  ])

  puts "   - Creating feedback history..."
  users[:alex].feedback_histories.create!(subject: 'Q3 Marketing Plan', content: 'The plan is well-structured, but the timeline seems aggressive.', created_at: '2025-08-15T09:00:00Z', sentiment: 'Neutral')
  users[:casey].feedback_histories.create!(subject: 'New Feature Design', content: 'I love the new UI! It\'s much more intuitive.', created_at: '2025-08-14T11:30:00Z', sentiment: 'Positive')
  users[:taylor].feedback_histories.create!(subject: 'API Documentation', content: 'The endpoint for user auth is missing examples.', created_at: '2025-08-12T16:45:00Z', sentiment: 'Negative')
  users[:jordan].feedback_histories.create!(subject: 'Onboarding Process', content: 'The new hire checklist is helpful, but some links are broken.', created_at: '2025-08-11T14:00:00Z', sentiment: 'Negative')

  puts "   - Creating leaderboard..."
  Leaderboard.create!([
    { user: users[:alex],   points: 4250, badges: '🚀,🎯,🔥' },
    { user: users[:casey],  points: 3980, badges: '💡,🎯' },
    { user: users[:taylor], points: 3710, badges: '🤝' },
    { user: users[:jordan], points: 3500, badges: '🚀' },
    { user: users[:jamie],  points: 3200, badges: '💡,🤝' },
    { user: users[:morgan], points: 2950, badges: '🎯' }
  ])

  puts "   - Creating dashboard items..."
  AgendaItem.create!([
    { type: 'article', title: 'The Art of Giving Constructive Feedback', category: 'Communication', due_date: '2025-08-18' },
    { type: 'meeting', title: 'Q3 Project Kickoff', category: 'Planning', due_date: '2025-08-19' },
    { type: 'article', title: 'Leading Without Authority', category: 'Leadership', due_date: '2025-08-20' }
  ])
  
  ActivityStream.create!([
    { user: users[:casey], action: 'completed the quest "Teamwork Titan".', created_at: Time.now - 5.minutes },
    { user: users[:alex], action: 'provided feedback on the "Q3 Marketing Plan".', created_at: Time.now - 2.hours },
    { user: users[:taylor], action: 'updated the status of task "Deploy Staging Server".', created_at: Time.now - 1.day },
    { user: users[:jamie], action: 'read the article "Leading Without Authority".', created_at: Time.now - 1.day },
    { user: users[:jordan], action: 'RSVP\'d to "Q3 Project Kickoff".', created_at: Time.now - 2.days }
  ])

  Meeting.create!([
    { title: 'Q3 Project Kickoff', meeting_date: '2025-08-19', status: 'Upcoming' },
    { title: 'Weekly Sync: Sprint 14', meeting_date: '2025-08-12', status: 'Complete' },
    { title: 'Design Review: New Feature', meeting_date: '2025-08-11', status: 'Complete' }
  ])
end

puts "Seeding complete."