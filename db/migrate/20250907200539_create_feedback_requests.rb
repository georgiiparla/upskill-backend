class CreateFeedbackRequests < ActiveRecord::Migration[7.2]
  def change
    
    # Migration for Model B (Public Forum)
    create_table :feedback_requests do |t|
        t.references :requester, foreign_key: { to_table: :users }, null: false # Who asked?
        t.string :topic, null: false
        t.text :details
        t.string :status, null: false, default: 'pending' # Status of the *request itself*
        t.timestamps
    end

    add_index :feedback_requests, :status

  end
end
