class UserQuest < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest

  # Mark quest as completed and award points
  def mark_completed!
    # For 'always' type quests, always award points even if already completed
    # For 'interval-based' type quests, only award if not already completed
    if quest.quest_type == 'always' || !completed?
      transaction do
        # For always-type quests, always update last_triggered_at
        # Set first_awarded_at only on first award (if it's currently NULL)
        if quest.quest_type == 'always'
          attrs = { completed: true, last_triggered_at: Time.current }
          attrs[:first_awarded_at] = Time.current if read_attribute(:first_awarded_at).nil?
          update!(attrs)
        else
          attrs = { completed: true }
          attrs[:first_awarded_at] = Time.current if read_attribute(:first_awarded_at).nil?
          update!(attrs) unless completed?
        end
        leaderboard = user.leaderboard || user.build_leaderboard(points: 0)
        leaderboard.points = (leaderboard.points || 0) + quest.points.to_i
        leaderboard.save!
      end
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
