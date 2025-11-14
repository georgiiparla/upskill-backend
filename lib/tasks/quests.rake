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
        title: "First Feedback Request",
        description: "Submit your first feedback request",
        points: 25,
        explicit: true,
        trigger_endpoint: "FeedbackRequestsController#create",
        quest_type: "repeatable",
        reset_interval_seconds: 1.year
      },
      {
        title: "Give Feedback",
        description: "Provide constructive feedback on someone's request",
        points: 50,
        explicit: true,
        trigger_endpoint: "FeedbackSubmissionsController#create",
        quest_type: "repeatable",
        reset_interval_seconds: 1.year
      },
      {
        title: "Like Quality Feedback",
        description: "Show your appreciation by liking quality feedback",
        points: 10,
        explicit: true,
        trigger_endpoint: "FeedbackSubmissionsController#like",
        quest_type: "repeatable",
        reset_interval_seconds: 7.days
      },
      {
        title: "Update Your Agenda",
        description: "Keep your agenda items up to date",
        points: 15,
        explicit: false,
        trigger_endpoint: "AgendaItemsController#update",
        quest_type: "repeatable",
        reset_interval_seconds: 1.day
      },
      {
        title: "Daily Login",
        description: "Log in daily to earn points",
        points: 5,
        explicit: false,
        trigger_endpoint: "AuthController#google_callback",
        quest_type: "repeatable",
        reset_interval_seconds: 1.day
      },
      {
        title: "Receive Quality Recognition",
        description: "Earn points when others like your feedback",
        points: 3,
        explicit: true,
        trigger_endpoint: "FeedbackSubmissionsController#like_received",
        quest_type: "always",
        reset_interval_seconds: nil
      },
    ])

    puts "  - Created #{quests.length} quests"
    puts "Quest seeding complete!"
  end
end
