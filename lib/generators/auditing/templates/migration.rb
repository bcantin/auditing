class CreateAudits < ActiveRecord::Migration
  def self.up
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
    
    add_index :audits, [:auditable_type, :auditable_id]
    add_index :audits, [:association_type, :association_id]
  end

  def self.down
    drop_table :audits
  end
end
