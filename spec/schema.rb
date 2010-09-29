ActiveRecord::Schema.define(:version => 0) do
  
  create_table :audits, :force => true do |t|
    t.string  :action
    t.string  :auditable_type
    t.integer :auditable_id
    t.string  :association_type
    t.integer :association_id
    t.string  :field_name
    t.string  :old_value
    t.string  :new_value
    # t.integer :user_id
    t.boolean :undoable, :default => true
    t.timestamps
  end  
  
  create_table :schools, :force => true do |t|
    t.string   :name
    t.datetime :established_on
    t.timestamps
  end
  
  create_table :cars, :force => true do |t|
    t.string  :name
    t.integer :auto_maker_id
    t.timestamps
  end
  
  create_table :auto_makers, :force => true do |t|
    t.string :name
    t.timestamps
  end

end