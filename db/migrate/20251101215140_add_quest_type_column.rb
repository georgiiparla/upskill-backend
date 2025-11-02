class AddQuestTypeColumn < ActiveRecord::Migration[7.0]
  def change
    # Add quest_type: 'repeatable' (has reset period) or 'always' (always gives points, no reset)
    add_column :quests, :quest_type, :string, default: 'repeatable', null: false

    # Add index for faster lookups
    add_index :quests, :quest_type
  end
end
