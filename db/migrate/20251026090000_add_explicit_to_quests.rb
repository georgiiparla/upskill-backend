class AddExplicitToQuests < ActiveRecord::Migration[7.2]
  def change
    add_column :quests, :explicit, :boolean, null: false, default: true
    add_index :quests, :explicit
  end
end
