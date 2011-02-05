class Audit < ActiveRecord::Base

  include Auditing::Auditor
  belongs_to :auditable,   :polymorphic => true
  belongs_to :association, :polymorphic => true
  
end
