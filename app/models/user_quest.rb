class UserQuest < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest

  # Mark quest as completed and award points ATOMICALLY
  def mark_completed!
    # For 'always' type quests, always award points even if already completed
    # For 'interval-based' type quests, only award if not already completed
    should_award = quest.quest_type == 'always' || !completed?
    
    return unless should_award

    transaction do
      # Snapshot the current quest points
      points_to_award = quest.points.to_i

      # 1. Update status
      attrs = { 
        completed: true, 
        points_snapshot: points_to_award # Save snapshot for future accuracy
      }
      
      # For always-type quests, update last_triggered_at
      if quest.quest_type == 'always'
        attrs[:last_triggered_at] = Time.current
      end
      
      # Set first_awarded_at only on first award
      attrs[:first_awarded_at] = Time.current if read_attribute(:first_awarded_at).nil?
      
      update!(attrs)

      # 2. Ensure leaderboard exists (atomic check)
      leaderboard = user.leaderboard || user.create_leaderboard(points: 0)
      
      # 3. ATOMIC UPDATE: Prevent race conditions causing lost points
      # We use update_counters which issues a SQL: UPDATE ... SET points = points + X
      Leaderboard.update_counters(leaderboard.id, points: points_to_award)
    end
  end

  # Mark quest as uncompleted and remove points ATOMICALLY
  def mark_uncompleted!
    should_proceed = completed? || quest.quest_type == 'always'
    return unless should_proceed

    transaction do
      # 1. Determine points to revert
      # Prefer the snapshot if it exists (historical accuracy), otherwise fallback to current quest points
      points_to_revert = points_snapshot.to_i > 0 ? points_snapshot : quest.points.to_i

      # 2. Update status
      # For interval quests, we mark as false. For always quests, we just deduct.
      update!(completed: false)

      # 3. ATOMIC DECREMENT: Prevent race conditions
      leaderboard = user.leaderboard
      if leaderboard
        # Atomic decrement
        Leaderboard.update_counters(leaderboard.id, points: -points_to_revert)
        
        # Safety check to clamp at 0 if race condition drove it negative
        leaderboard.reload
        if leaderboard.points < 0
          leaderboard.update_column(:points, 0)
        end
      end
    end
  end
end