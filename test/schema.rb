ActiveRecord::Schema.define(:version => 3) do
  create_table :transactionals, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :other_id, :integer
    t.timestamps
  end
  
  create_table :transactional_facts, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :other_id, :integer
    t.timestamps
  end
  
end
