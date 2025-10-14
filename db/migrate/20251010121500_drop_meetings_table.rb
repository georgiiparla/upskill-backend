class DropMeetingsTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :meetings if table_exists?(:meetings)
  end

  def down
    create_table :meetings do |t|
      t.string :title
      t.datetime :meeting_date
      t.string :status
      t.text :notes
      t.timestamps
    end
  end
end
