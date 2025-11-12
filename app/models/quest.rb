class Quest < ActiveRecord::Base
  has_many :user_quests, dependent: :destroy
  has_one :reset_schedule, class_name: 'QuestReset', dependent: :destroy

  attribute :explicit, :boolean, default: true
  attribute :quest_type, :string, default: 'repeatable'

  validates :title, presence: true
  validates :trigger_endpoint, uniqueness: true, allow_nil: true
  validates :quest_type, inclusion: { in: %w(repeatable always), message: "%{value} is not valid" }

  # Get or initialize the reset schedule for this quest
  def reset_schedule
    super || create_reset_schedule(reset_at: Time.current)
  end

  # Check if enough time has passed for a global reset
  def should_reset_globally?
    return false unless reset_interval_seconds&.positive?

    last_reset = reset_schedule.reset_at
    return true unless last_reset

    (Time.current - last_reset) >= reset_interval_seconds
  end

  # Perform global reset: reset all users' completed quests
  def reset_all_users!
    return unless reset_interval_seconds&.positive?

    transaction do
      user_quests.where(completed: true).update_all(completed: false)
      reset_schedule.update!(reset_at: Time.current)
    end
  end

  # Get next reset timestamp
  def next_reset_at
    return nil unless reset_interval_seconds&.positive?
    
    last_reset = reset_schedule.reset_at
    last_reset + reset_interval_seconds
  end

  # Check if quest will reset on next trigger
  def will_reset_on_next_trigger?
    should_reset_globally?
  end
end

