class CreateMantras < ActiveRecord::Migration[6.0]
  def change
    create_table :mantras do |t|
      t.string :text, null: false
      t.timestamps
    end
  end
end
