class ChangeLightbulbToStarInAgendaItems < ActiveRecord::Migration[7.0]
  def up
    AgendaItem.where(icon_name: 'Lightbulb').update_all(icon_name: 'Star')
  end

  def down
    AgendaItem.where(icon_name: 'Star').update_all(icon_name: 'Lightbulb')
  end
end
