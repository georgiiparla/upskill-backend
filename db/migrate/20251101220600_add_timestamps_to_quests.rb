class AddTimestampsToQuests < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:quests, :created_at)
      add_timestamps :quests, default: Time.current
    end
  end
end
