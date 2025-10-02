puts "Seeding database with mock data..."

ActiveRecord::Base.transaction do
  puts "   - Deleting old data..."
  [ActivityStream, FeedbackSubmission, FeedbackRequest, Leaderboard, Quest, AgendaItem, Meeting, User].each(&:destroy_all)

  puts "   - Creating mock users..."
  users = {}
  users[:alex]   = User.create!(username: 'Mock User Alex',   email: 'alex@example.com',   password: 'password123')
  users[:casey]  = User.create!(username: 'Mock User Casey',  email: 'casey@example.com',  password: 'password123')
  users[:taylor] = User.create!(username: 'Mock User Taylor', email: 'taylor@example.com', password: 'password123')
  users[:jordan] = User.create!(username: 'Mock User Jordan', email: 'jordan@example.com', password: 'password123')
  users[:jamie]  = User.create!(username: 'Mock User Jamie',  email: 'jamie@example.com',  password: 'password123')
  users[:morgan] = User.create!(username: 'Mock User Morgan', email: 'morgan@example.com', password: 'password123')

  puts "   - Creating mock quests..."
  Quest.create!([
    { title: 'Adaptability Ace', description: 'Complete the "Handling Change" module and score 90% on the quiz.', points: 150, progress: 100, completed: true },
    { title: 'Communication Pro', description: 'Provide constructive feedback on 5 different project documents.', points: 200, progress: 60, completed: false },
    { title: 'Leadership Leap', description: 'Lead a project planning session and submit the meeting notes.', points: 250, progress: 0, completed: false },
    { title: 'Teamwork Titan', description: 'Successfully complete a paired programming challenge.', points: 100, progress: 100, completed: true }
  ])

  puts "   - Creating mock feedback requests..."
  request1 = users[:alex].feedback_requests.create!(
    topic: "Review my Q4 strategy presentation deck",
    details: "I'm specifically looking for feedback on slides 3-5 regarding market analysis. Is the data clear enough?",
    tag: "strategyReviewMockTag123",
    visibility: 'public'
  )

  request2 = users[:casey].feedback_requests.create!(
    topic: "Code review for new API endpoint",
    details: "Before I merge this branch, can someone check the error handling logic in `auth_controller.rb`?",
    tag: "apiRefactorMockTag456",
    visibility: 'requester_only'
  )
  
  future_expiry = Time.now + 7.days
  request1.update_column(:expires_at, future_expiry)
  request2.update_column(:expires_at, future_expiry)
  
  request3 = users[:jordan].feedback_requests.create!(
    topic: "Thoughts on the new onboarding doc?",
    details: "This is a draft of the new onboarding document for junior developers. Is it clear and comprehensive?",
    tag: "onboardingDocMockTag789",
    status: 'closed'
  )
  request3.update_column(:expires_at, Time.now - 2.days)


  puts "   - Creating mock feedback submissions..."
  users[:taylor].feedback_submissions.create!(
    feedback_request: request1,
    subject: "Re: Q4 Strategy Deck",
    content: "Slides 3 and 4 are solid. Slide 5's graph is a bit confusing; maybe try a bar chart instead of a pie chart?",
    sentiment: 2
  )

  users[:alex].feedback_submissions.create!(
    feedback_request: request2,
    subject: "Re: API Endpoint Review",
    content: "Looks good overall. I added one suggestion to handle nil inputs to prevent a potential 500 error.",
    sentiment: 3
  )

  users[:casey].feedback_submissions.create!(
    feedback_request: request3,
    subject: "Re: Onboarding Doc",
    content: "This looks fantastic! It's much clearer than the old one. I'd just add a link to the dev environment setup guide.",
    sentiment: 3
  )

  puts "   - Creating mock leaderboard..."
  Leaderboard.create!([
    { user: users[:alex],   points: 4250, badges: '🚀,🎯,🔥' },
    { user: users[:casey],  points: 3980, badges: '💡,🎯' },
    { user: users[:taylor], points: 3710, badges: '🤝' },
    { user: users[:jordan], points: 3500, badges: '🚀' },
    { user: users[:jamie],  points: 3200, badges: '💡,🤝' },
    { user: users[:morgan], points: 2950, badges: '🎯' }
  ])


  puts "   - Creating mock dashboard items..."
  AgendaItem.create!([
    { type: 'article', title: 'The Art of Giving Constructive Feedback', category: 'Communication', due_date: '2025-08-18', editor: users[:alex], link: 'https://hbr.org/2018/05/the-right-way-to-respond-to-negative-feedback' },
    { type: 'meeting', title: 'Q3 Project Kickoff', category: 'Planning', due_date: '2025-08-19', editor: users[:casey] },
    { type: 'article', title: 'Leading Without Authority', category: 'Leadership', due_date: '2025-08-20', editor: users[:alex] }
  ])

  puts "   - Creating new, structured mock activity stream..."
  
  ActivityStream.create!(
    actor: users[:alex],
    target: request1,
    event_type: 'feedback_requested',
    created_at: request1.created_at
  )

  ActivityStream.create!(
    actor: nil,
    target: request3,
    event_type: 'feedback_closed',
    created_at: request3.updated_at
  )

  agenda_item = AgendaItem.find_by!(title: 'Q3 Project Kickoff')
  ActivityStream.create!(
    actor: users[:casey],
    target: agenda_item,
    event_type: 'agenda_updated',
    created_at: Time.now - 1.hour
  )
  
  Meeting.create!([
    { title: 'Q3 Project Kickoff', meeting_date: '2025-08-19', status: 'Upcoming' },
    { title: 'Weekly Sync: Sprint 14', meeting_date: '2025-08-12', status: 'Complete' },
    { title: 'Design Review: New Feature', meeting_date: '2025-08-11', status: 'Complete' }
  ])
end

puts "Seeding complete."