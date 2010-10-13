ActiveRecord::Schema.define(:version => 0) do
  
  create_table :audits do |t|
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
  
  create_table :schools do |t|
    t.string   :name
    t.datetime :established_on
    t.timestamps
  end
  
  create_table :cars do |t|
    t.string  :name
    t.integer :auto_maker_id
    t.timestamps
  end
  
  create_table :auto_makers do |t|
    t.string :name
    t.timestamps
  end
  
  create_table :companies do |t|
    t.string :name
    t.timestamps
  end
  
  create_table :phone_numbers do |t|
    t.string  :number
    t.string  :extension
    t.string  :phoneable_type
    t.integer :phoneable_id
    t.timestamps
  end
  
  create_table :people do |t|
    t.string :first_name
    t.string :last_name
    t.timestamps
  end
  
  create_table :employments do |t|
    t.integer  :person_id
    t.integer  :company_id
    t.string   :start_date
    t.timestamps
  end

end