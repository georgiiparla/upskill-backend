class CreateWhitelistedEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :whitelisted_emails do |t|
      t.string :email, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :whitelisted_emails, "lower(email)", unique: true
  end
end
