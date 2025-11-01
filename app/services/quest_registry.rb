# frozen_string_literal: true

class QuestRegistry
  # Load quest definitions from YAML
  # Works with both Rails and Sinatra
  APP_ROOT = File.expand_path('../../..', __FILE__)
  QUESTS = YAML.load_file(File.join(APP_ROOT, 'config/quests.yml'))['quests'].freeze

  # All quest codes as constants for type safety
  QUEST_CODES = {
    CREATE_FEEDBACK_REQUEST: :create_feedback_request,
    GIVE_FEEDBACK: :give_feedback,
    LIKE_FEEDBACK: :like_feedback,
    UPDATE_AGENDA: :update_agenda,
    DAILY_LOGIN: :daily_login,
  }.freeze

  class << self
    # Get a quest by code
    # @param code [String, Symbol] - Quest code
    # @return [Hash] - Quest definition or nil
    def find(code)
      QUESTS[code.to_sym]
    end

    # Get all quests
    # @return [Hash] - All quest definitions
    def all
      QUESTS
    end

    # Get all explicit quests (shown to users)
    # @return [Hash] - Explicit quests only
    def explicit_only
      QUESTS.select { |_code, quest| quest['explicit'] }
    end

    # Get all implicit quests (hidden from UI)
    # @return [Hash] - Implicit quests only
    def implicit_only
      QUESTS.reject { |_code, quest| quest['explicit'] }
    end

    # Check if a quest exists
    # @param code [String, Symbol] - Quest code
    # @return [Boolean]
    def exists?(code)
      QUESTS.key?(code.to_sym)
    end

    # Get quest by category
    # @param category [String] - Quest category
    # @return [Hash] - Quests in category
    def by_category(category)
      QUESTS.select { |_code, quest| quest['category'] == category }
    end

    # Get repeatable quests (can be completed multiple times)
    # @return [Hash] - Repeatable quests
    def repeatable_only
      QUESTS.select { |_code, quest| quest['repeatable'] }
    end

    # Get non-repeatable quests (one-time only)
    # @return [Hash] - Non-repeatable quests
    def non_repeatable_only
      QUESTS.reject { |_code, quest| quest['repeatable'] }
    end
  end
end
