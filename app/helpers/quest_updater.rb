# frozen_string_literal: true

# Helper module responsible for updating quest progress & awarding points
module QuestUpdater
  module_function

  def complete_for(user, quest_code)
    quest = Quest.find_by(code: quest_code)
    return unless quest && user

    user_quest = user.user_quests.find_by(quest: quest)
    # Lazily create association if somehow missing
    user_quest ||= user.user_quests.create!(quest: quest)

    user_quest.mark_completed!
  end
end
