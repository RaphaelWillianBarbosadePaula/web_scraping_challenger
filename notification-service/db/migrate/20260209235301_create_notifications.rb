class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.string :event_type, null: false
      t.json :data

      t.timestamps
    end
  end
end
