class CreatePtkmsUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false
      t.boolean :admin, default: false, null: false

      t.timestamps
    end
    
    add_index :ptkms_users, :name, :unique  => true         
  end
end
