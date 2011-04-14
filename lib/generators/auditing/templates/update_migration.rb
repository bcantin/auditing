class UpdateAudits < ActiveRecord::Migration
  def self.up
    change_column :audits, :old_value, :text
    change_column :audits, :new_value, :text
  end

  def self.down
    change_column :audits, :old_value, :string
    change_column :audits, :new_value, :string
  end
end
