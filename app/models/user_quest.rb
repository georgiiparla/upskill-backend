class UserQuest < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest

  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  # Marks quest as completed for the user and awards points
  def mark_completed!
    return if completed?

    transaction do
      update!(progress: 1, completed: true)
      leaderboard = user.leaderboard || user.build_leaderboard(points: 0)
      leaderboard.points = (leaderboard.points || 0) + quest.points.to_i
      leaderboard.save!
    end
  end
end
