class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.string  :action
      t.string  :auditable_type
      t.integer :auditable_id
      t.string  :audit_assoc_type
      t.integer :audit_assoc_id
      t.string  :field_name
      t.text    :old_value
      t.text    :new_value
      # t.integer :user_id
      t.boolean :undoable, :default => true
      t.timestamps
    end
    
    add_index :audits, [:auditable_type, :auditable_id]
    add_index :audits, [:audit_assoc_type, :audit_assoc_id]
  end

  def self.down
    drop_table :audits
  end
end
