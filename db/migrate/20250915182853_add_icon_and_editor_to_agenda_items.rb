class AddIconAndEditorToAgendaItems < ActiveRecord::Migration[7.2]
  def change
    add_column :agenda_items, :icon_name, :string, default: 'ClipboardList', null: false

    add_reference :agenda_items, :editor, foreign_key: { to_table: :users }, null: true
  end
end