puts "Seeding database with mock data..."

ActiveRecord::Base.transaction do
  puts "   - Deleting old data..."
  [ActivityStream, FeedbackSubmission, FeedbackRequest, Leaderboard, UserQuest, Quest, AgendaItem, User].each(&:destroy_all)

  puts "   - Creating mock users..."
  users = {}
  users[:alex]   = User.create!(username: 'Mock User Alex',   email: 'alex@example.com',   password: 'password123')
  users[:casey]  = User.create!(username: 'Mock User Casey',  email: 'casey@example.com',  password: 'password123')
  users[:taylor] = User.create!(username: 'Mock User Taylor', email: 'taylor@example.com', password: 'password123')
  users[:jordan] = User.create!(username: 'Mock User Jordan', email: 'jordan@example.com', password: 'password123')
  users[:jamie]  = User.create!(username: 'Mock User Jamie',  email: 'jamie@example.com',  password: 'password123')
  users[:morgan] = User.create!(username: 'Mock User Morgan', email: 'morgan@example.com', password: 'password123')

  # Create progression records for existing users (created above)
  User.find_each { |u| u.send(:initialize_progression) }

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
    subject: "Q4 Strategy Deck",
    content: "Slides 3 and 4 are solid. Slide 5's graph is a bit confusing; maybe try a bar chart instead of a pie chart?",
    sentiment: 2
  )

  users[:alex].feedback_submissions.create!(
    feedback_request: request2,
    subject: "API Endpoint Review",
    content: "Looks good overall. I added one suggestion to handle nil inputs to prevent a potential 500 error.",
    sentiment: 3
  )

  users[:casey].feedback_submissions.create!(
    feedback_request: request3,
    subject: "Onboarding Doc",
    content: "This looks fantastic! It's much clearer than the old one. I'd just add a link to the dev environment setup guide.",
    sentiment: 3
  )

  puts "   - Creating mock leaderboard..."
  Leaderboard.create!([
    { user: users[:alex],   points: 0, badges: nil },
    { user: users[:casey],  points: 0, badges: nil },
    { user: users[:taylor], points: 0, badges: nil },
    { user: users[:jordan], points: 0, badges: nil },
    { user: users[:jamie],  points: 0, badges: nil },
    { user: users[:morgan], points: 0, badges: nil }
  ])


  puts "   - Creating mantras..."

  mantras = Mantra.create!([
    { text: "Better Me + Better You = Better Us" },
    { text: 'When Furious, Get Curious' },
    { text: 'You Are Part Of A Tribe; Never Walk Alone' },
    { text: 'Serve Before Being Served' },
    { text: 'Stop Starting, Start Finishing' },
    { text: 'Listen To Understand' },
    { text: 'One Small Step at a Time' },
    { text: "Be Quick But Don't Hurry" },
    { text: "Leave It Better" },
    { text: "Be The Driver or Navigator, Not A Passenger" },
    { text: "Feedback Is The Breakfast of Champions" },
    { text: "Facts Instead Assumptions" },
    { text: 'Stop The Line' },
    { text: 'Cutting Corners Hurts' }
  ])

  # Create initial system mantra item
  AgendaItem.create!(
    title: "Mantra of the week: #{mantras.first.text}",
    icon_name: 'Star',
    is_system_mantra: true,
    mantra_id: mantras.first.id,
    editor: nil,
    due_date: Date.new(2025, 1, 1),
    type: 'mantra'
  )

  puts "   - Creating mock dashboard items..."
  AgendaItem.create!([
    { type: 'article', title: 'The Art of Giving Constructive Feedback', category: 'Communication', due_date: '2025-08-18', editor: users[:alex], link: 'https://hbr.org/2018/05/the-right-way-to-respond-to-negative-feedback' },
    { type: 'article', title: 'Leading Without Authority', category: 'Leadership', due_date: '2025-08-20', editor: users[:casey] }
  ])

  puts "   - Creating new, structured mock activity stream..."
  
  ActivityStream.create!(
    actor: users[:alex],
    target: request1,
    event_type: 'feedback_requested',
    created_at: request1.created_at
  )

  ActivityStream.create!(
    actor: users[:jordan],
    target: request3,
    event_type: 'feedback_closed',
    created_at: request3.updated_at
  )

  agenda_item = AgendaItem.find_by(title: 'The Art of Giving Constructive Feedback')
  if agenda_item
    ActivityStream.create!(
      actor: users[:casey],
      target: agenda_item,
      event_type: 'agenda_updated',
      created_at: Time.now - 1.hour
    )
  end

end

puts "Seeding complete."