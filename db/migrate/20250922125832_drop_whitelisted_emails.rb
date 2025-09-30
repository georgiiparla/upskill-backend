class DropWhitelistedEmails < ActiveRecord::Migration[7.2]
  def up
    drop_table :whitelisted_emails
  end

  def down
    create_table :whitelisted_emails do |t|
      t.string :email, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :whitelisted_emails, "lower(email)", unique: true
  end
end