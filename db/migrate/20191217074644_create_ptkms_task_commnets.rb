class CreatePtkmsTaskCommnets < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_task_commnets do |t|
      t.integer :task_id,null: false
      t.string :name,null: false
      t.text :body,null: false

      t.timestamps
    end
    
    add_index :ptkms_task_commnets, :task_id     
  end
end
