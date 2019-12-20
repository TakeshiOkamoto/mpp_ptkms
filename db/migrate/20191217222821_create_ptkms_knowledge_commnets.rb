class CreatePtkmsKnowledgeCommnets < ActiveRecord::Migration[6.0]
  def change
    create_table :ptkms_knowledge_commnets do |t|
      t.integer :knowledge_id,null: false
      t.string :name,null: false
      t.text :body,null: false

      t.timestamps
    end
    
    add_index :ptkms_knowledge_commnets, :knowledge_id         
  end
end
