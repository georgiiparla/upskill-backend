class RefactorActivityStreams < ActiveRecord::Migration[7.2]
  def change
    ActivityStream.destroy_all

    rename_column :activity_streams, :user_id, :actor_id

    remove_column :activity_streams, :action, :text

    add_column :activity_streams, :event_type, :string, null: false
    add_column :activity_streams, :target_type, :string
    add_column :activity_streams, :target_id, :integer

    add_index :activity_streams, [:target_type, :target_id], name: "index_activity_streams_on_target"
  end
end