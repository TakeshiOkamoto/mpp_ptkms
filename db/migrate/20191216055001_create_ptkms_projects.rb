class CreatePtkmsProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_projects do |t|
      t.string :name
      t.string :client_name
      t.date :p_start
      t.date :p_end
      t.text :info
      t.boolean :show, default: true, null: false

      t.timestamps
    end
    
    add_index :ptkms_projects, :name, :unique  => true      
  end
end
