namespace :db do
  desc "Seed/reseed quest definitions (removes old, creates new)"
  task seed_quests: :environment do
    puts "Seeding quest definitions..."

    puts "  - Deleting old quests..."
    Quest.destroy_all

    puts "  - Creating new quests..."
    
    quests = Quest.create!([
      {
        title: "Ask for Feedback (Presentation)",
        description: "Prepare and deliver your offline presentation/feedback request",
        points: 25, 
        explicit: false,
        trigger_endpoint: "FeedbackRequestsController#create",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Write feedback",
        description: "Submit thoughtful feedback on a request",
        points: 5, # LOWERED: Now requires 5 feedbacks to equal 1 presentation.
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#create",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Weekly agenda update",
        description: "Update the weekly agenda for this week",
        points: 5, # Adjusted relative to writing feedback.
        explicit: true,
        trigger_endpoint: "AgendaItemsController#update",
        quest_type: "interval-based",
        reset_interval_seconds: 1.week
      },
      {
        title: "Receive a like on your feedback",
        description: "Earn points when someone likes your feedback",
        points: 2, 
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#like_received",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Daily check-in",
        description: "Log in each day to stay connected",
        points: 1, # KEEP LOW: Do not let passive login equal active work.
        explicit: true,
        trigger_endpoint: "AuthController#google_callback",
        quest_type: "interval-based",
        reset_interval_seconds: 1.day
      },
      {
        title: "Like a teammate's feedback",
        description: "Like feedback written by someone else",
        points: 1, 
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#like",
        quest_type: "always",
        reset_interval_seconds: nil
      }
    ])

    puts "  - Created #{quests.length} quests"
    puts "Quest seeding complete!"
  end
end