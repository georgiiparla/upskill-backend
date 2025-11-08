# Quest Middleware for Sinatra - OOP approach
# Usage: In your controller action, call:
#   QuestMiddleware.trigger(current_user, 'FeedbackRequestsController#create')
#
# Quest Types:
#   'repeatable' - Awards points once per reset_interval_seconds (daily, weekly, etc)
#   'always'     - Awards points every time endpoint is triggered (no reset limit)

class QuestMiddleware
  def self.trigger(user, endpoint)
    return nil if user.nil? || endpoint.blank?

    quest = Quest.find_by(trigger_endpoint: endpoint)
    return nil unless quest

    user_quest = user.user_quests.find_or_create_by(quest: quest)

    # For 'always' type quests, always award points (no reset check needed)
    # For 'repeatable' type quests, check if enough time has passed since last reset
    if quest.quest_type == 'always'
      # Always type: always give points, regardless of completion status
      user_quest.mark_completed!
    elsif quest.quest_type == 'repeatable'
      # Repeatable type: check reset schedule
      if quest.should_reset_globally?
        quest.reset_all_users!
        # After reset, need to reload the user_quest to get the updated completion status
        user_quest.reload
      end

      # Award points if not already completed (in this reset period)
      user_quest.mark_completed! unless user_quest.completed?
    end

    user_quest
  end

  def self.revert(user, endpoint)
    return nil if user.nil? || endpoint.blank?

    quest = Quest.find_by(trigger_endpoint: endpoint)
    return nil unless quest

    user_quest = user.user_quests.find_by(quest: quest)
    return nil unless user_quest

    user_quest.mark_uncompleted!
    user_quest
  end
end

