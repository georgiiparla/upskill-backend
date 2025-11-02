class UserQuest < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest

  # Mark quest as completed and award points
  def mark_completed!
    return if completed?

    transaction do
      update!(completed: true)
      leaderboard = user.leaderboard || user.build_leaderboard(points: 0)
      leaderboard.points = (leaderboard.points || 0) + quest.points.to_i
      leaderboard.save!
    end
  end

  # Mark quest as uncompleted and remove points
  def mark_uncompleted!
    return unless completed?

    transaction do
      update!(completed: false)

      leaderboard = user.leaderboard
      if leaderboard
        new_points = (leaderboard.points || 0) - quest.points.to_i
        leaderboard.points = new_points.negative? ? 0 : new_points
        leaderboard.save!
      end
    end
  end
end
