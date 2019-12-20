class CreatePtkmsKnowledges < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_knowledges do |t|
      t.integer :project_id, null: false
      t.string :title, null: false
      t.boolean :show, default: true, null: false

      t.timestamps
    end
    
    add_index :ptkms_knowledges, :project_id
    add_index :ptkms_knowledges, :title        
  end
end
