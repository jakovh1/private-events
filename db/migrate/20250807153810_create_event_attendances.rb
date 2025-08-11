class CreateEventAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :event_attendances do |t|
      t.references :event, foreign_key: true
      t.references :attendee, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :event_attendances, [ :attendee_id, :event_id ], unique: true
  end
end
