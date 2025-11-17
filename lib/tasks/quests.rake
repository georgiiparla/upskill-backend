namespace :db do
  desc "Seed/reseed quest definitions (removes old, creates new)"
  task seed_quests: :environment do
    puts "Seeding quest definitions..."

    # Remove all existing quests (cascades to user_quests and quest_resets)
    puts "  - Deleting old quests..."
    Quest.destroy_all

    puts "  - Creating new quests..."
    quests = Quest.create!([
      {
        title: "Ask for Feedback",
        description: "Create a feedback request",
        points: 15,
        explicit: false,
        trigger_endpoint: "FeedbackRequestsController#create",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Like a teammate's feedback",
        description: "Like feedback written by someone else",
        points: 7,
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#like",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Receive a like on your feedback",
        description: "Earn points when someone likes your feedback",
        points: 5,
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#like_received",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Write feedback",
        description: "Submit thoughtful feedback on a request",
        points: 11,
        explicit: false,
        trigger_endpoint: "FeedbackSubmissionsController#create",
        quest_type: "always",
        reset_interval_seconds: nil
      },
      {
        title: "Weekly agenda update",
        description: "Update the weekly agenda for this week",
        points: 8,
        explicit: true,
        trigger_endpoint: "AgendaItemsController#update",
        quest_type: "interval-based",
        reset_interval_seconds: 1.week
      },
      {
        title: "Daily check-in",
        description: "Log in each day to stay connected",
        points: 3,
        explicit: true,
        trigger_endpoint: "AuthController#google_callback",
        quest_type: "interval-based",
        reset_interval_seconds: 1.day
      }
    ])

    puts "  - Created #{quests.length} quests"
    puts "Quest seeding complete!"
  end
end
