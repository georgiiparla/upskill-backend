class AddCodeToQuestsAndCreateUserQuests < ActiveRecord::Migration[7.2]
  def change
    # Add unique code identifier to quests for easier referencing in business logic
    add_column :quests, :code, :string
    add_index  :quests, :code, unique: true

    # Create join table that tracks each user's progress on a particular quest
    create_table :user_quests do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true

      t.integer :progress,  default: 0,  null: false
      t.boolean :completed, default: false, null: false

      t.timestamps
    end

    add_index :user_quests, [:user_id, :quest_id], unique: true
  end
end
