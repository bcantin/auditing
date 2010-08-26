ActiveRecord::Schema.define(:version => 0) do
  
  create_table :schools, :force => true do |t|
    t.string :name
    t.timestamps
  end
  
end