class CreateProcessedEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :processed_events do |t|
      t.string :event_id, null: false
      t.string :event_name, null: false
      t.datetime :occurred_at
      t.timestamps
    end

    add_index :processed_events, :event_id, unique: true
  end
end
