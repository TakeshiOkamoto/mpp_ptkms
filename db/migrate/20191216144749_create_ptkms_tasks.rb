class CreatePtkmsTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_tasks do |t|
      t.integer :project_id, null: false
      t.string  :title, null: false
      t.integer :priority, null: false
      t.boolean :show, default: true, null: false

      t.timestamps
    end

    add_index :ptkms_tasks, :project_id
    add_index :ptkms_tasks, :title    
    add_index :ptkms_tasks, :priority                
  end
end
