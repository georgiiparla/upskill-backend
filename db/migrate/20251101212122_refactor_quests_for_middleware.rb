class RefactorQuestsForMiddleware < ActiveRecord::Migration[7.0]
  def change
    # Add new middleware-based columns to quests
    add_column :quests, :trigger_endpoint, :string, null: true
    add_column :quests, :reset_interval_seconds, :integer, null: true

    # Index for fast middleware lookup by endpoint
    add_index :quests, :trigger_endpoint, unique: true

    # Remove obsolete columns from user_quests
    # - last_completed_at: not needed with global resets
    remove_column :user_quests, :last_completed_at if column_exists?(:user_quests, :last_completed_at)
    
    # - progress: only ever used as 0 or 1, just use completed boolean
    remove_column :user_quests, :progress if column_exists?(:user_quests, :progress)

    # Remove obsolete quest columns
    # - code: only needed for YAML lookups, no longer used
    if index_exists?(:quests, :code)
      remove_index :quests, column: :code
    end
    remove_column :quests, :code if column_exists?(:quests, :code)

    # Track global reset times per quest (when everyone's quests were last reset)
    create_table :quest_resets do |t|
      t.references :quest, null: false, foreign_key: true
      t.datetime :reset_at, null: false
      t.timestamps
    end
  end
end
