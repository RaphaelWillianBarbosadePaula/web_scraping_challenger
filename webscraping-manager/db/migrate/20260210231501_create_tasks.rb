class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false, limit: 100
      t.string :url, null: false
      t.string :status, null: false
      t.integer :user_id, null: false
      t.json :result_data

      t.timestamps
    end
  end
end
