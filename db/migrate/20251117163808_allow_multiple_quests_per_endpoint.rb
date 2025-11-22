class AllowMultipleQuestsPerEndpoint < ActiveRecord::Migration[7.0]
  def change
    if index_exists?(:quests, :trigger_endpoint)
      remove_index :quests, :trigger_endpoint
    end
    add_index :quests, :trigger_endpoint unless index_exists?(:quests, :trigger_endpoint)
  end
end
