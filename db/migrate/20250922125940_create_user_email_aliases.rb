class CreateUserEmailAliases < ActiveRecord::Migration[7.2]
  def change
    create_table :user_email_aliases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false

      t.timestamps
    end

    add_index :user_email_aliases, "lower(email)", unique: true
  end
end