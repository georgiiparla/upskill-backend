class RemoveUniqueIndexFromUsernames < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :username, if_exists: true
  end
end