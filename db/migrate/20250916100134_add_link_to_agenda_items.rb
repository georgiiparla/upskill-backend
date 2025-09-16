class AddLinkToAgendaItems < ActiveRecord::Migration[7.2]
  def change
    add_column :agenda_items, :link, :string
  end
end