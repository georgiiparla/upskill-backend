class AddTimestampsToAgendaItems < ActiveRecord::Migration[7.2]
  def change
    add_timestamps :agenda_items, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end