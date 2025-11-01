# frozen_string_literal: true

require 'logger'
require_relative '../services/quest_registry'

LOGGER = Logger.new($stdout)

# Helper module responsible for updating quest progress & awarding points
# Handles cases where quests may not exist in database gracefully
module QuestUpdater
  module_function

  def complete_for(user, quest_code)
    return if user.nil? || quest_code.nil?

    quest = Quest.find_by(code: quest_code)
    
    # Quest doesn't exist in database - log and return silently
    # This prevents errors when quests are deleted but code still tries to award them
    unless quest
      LOGGER.warn("QuestUpdater: Quest '#{quest_code}' not found in database. Skipping quest completion.")
      return false
    end

    user_quest = user.user_quests.find_by(quest: quest)
    # Lazily create association if somehow missing
    user_quest ||= user.user_quests.create!(quest: quest)

    # For repeatable quests, check if enough time has passed since last completion
    if is_repeatable_quest?(quest_code) && user_quest.completed?
      return false unless can_repeat_quest?(user_quest)
    end

    user_quest.mark_completed!
    true
  rescue StandardError => e
    LOGGER.error("QuestUpdater Error: #{e.message}\n#{e.backtrace.join("\n")}")
    false
  end

  # Revert a quest completion for the user (remove awarded points and mark not completed)
  def revert_for(user, quest_code)
    return if user.nil? || quest_code.nil?

    quest = Quest.find_by(code: quest_code)
    
    unless quest
      LOGGER.warn("QuestUpdater: Quest '#{quest_code}' not found in database. Skipping quest revert.")
      return false
    end

    user_quest = user.user_quests.find_by(quest: quest)
    return false unless user_quest

    user_quest.mark_uncompleted!
    true
  rescue StandardError => e
    LOGGER.error("QuestUpdater Error: #{e.message}\n#{e.backtrace.join("\n")}")
    false
  end

  def is_repeatable_quest?(quest_code)
    quest_registry = QuestRegistry.find(quest_code)
    quest_registry && quest_registry['repeatable']
  end

  def can_repeat_quest?(user_quest)
    # Check if 24 hours have passed since last completion
    return true if user_quest.updated_at.nil?
    
    time_since_last = Time.now - user_quest.updated_at
    time_since_last >= 24 * 60 * 60
  end
end
