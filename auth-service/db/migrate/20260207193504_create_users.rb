class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :nickname,        null: false, index: { unique: true }, limit: 20
      t.string :email,           null: false, index: { unique: true }, limit: 255
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
