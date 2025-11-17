# Quest Middleware for Sinatra - OOP approach
# Usage: In your controller action, call:
#   QuestMiddleware.trigger(current_user, 'FeedbackRequestsController#create')
#
# Quest Types:
#   'interval-based' - Awards points once per reset_interval_seconds (daily, weekly, etc)
#   'always'         - Awards points every time endpoint is triggered (no reset limit)

class QuestMiddleware
  def self.trigger(user, endpoint)
    return nil if user.nil? || endpoint.blank?

    quests = Quest.where(trigger_endpoint: endpoint)
    return nil if quests.empty?

    last_user_quest = nil

    quests.find_each do |quest|
      user_quest = user.user_quests.find_or_create_by(quest: quest)

      if quest.quest_type == 'always'
        user_quest.mark_completed!
      elsif quest.quest_type == 'interval-based'
        if quest.should_reset_globally?
          quest.reset_all_users!
          user_quest.reload
        end
        user_quest.mark_completed! unless user_quest.completed?
      end

      last_user_quest = user_quest
    end

    last_user_quest
  end

  def self.revert(user, endpoint)
    return nil if user.nil? || endpoint.blank?

    quests = Quest.where(trigger_endpoint: endpoint)
    return nil if quests.empty?

    last_user_quest = nil

    quests.find_each do |quest|
      user_quest = user.user_quests.find_by(quest: quest)
      next unless user_quest
      user_quest.mark_uncompleted!
      last_user_quest = user_quest
    end

    last_user_quest
  end
end

