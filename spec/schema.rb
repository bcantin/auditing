ActiveRecord::Schema.define(:version => 0) do
  
  create_table :schools, :force => true do |t|
    t.string   :name
    t.datetime :established_on
    t.timestamps
  end
  
end