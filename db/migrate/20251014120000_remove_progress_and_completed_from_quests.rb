class RemoveProgressAndCompletedFromQuests < ActiveRecord::Migration[7.2]
  def change
    remove_column :quests, :progress, :integer
    remove_column :quests, :completed, :boolean
  end
end
