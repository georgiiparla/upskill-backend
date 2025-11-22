class AddSystemFieldToAgendaItems < ActiveRecord::Migration[6.0]
  def change
    add_column :agenda_items, :is_system_mantra, :boolean, default: false, null: false
    add_column :agenda_items, :mantra_id, :integer
    add_index :agenda_items, :mantra_id
    add_foreign_key :agenda_items, :mantras, column: :mantra_id
  end
end
