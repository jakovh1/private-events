class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.text :name
      t.text :description
      t.text :date
      t.text :time

      t.timestamps
    end
  end
end
