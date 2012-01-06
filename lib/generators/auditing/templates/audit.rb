class Audit < ActiveRecord::Base

  include Auditing::Auditor
  belongs_to :auditable,   :polymorphic => true
  belongs_to :audit_assoc, :polymorphic => true
  
end
