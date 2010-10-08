module Auditing
  module AuditRelationship
    
    def audit_relationship_enabled(opts={})
      # include InstanceMethods
      # class_inheritable_accessor :auditing_fields
      # 
      # has_many :audits, :as => :auditable, :order => 'created_at DESC, id DESC'
      # 
      # self.auditing_fields = gather_fields_for_auditing(opts[:fields])
      # 
      # after_create :log_creation
      # after_update :log_update
    end
  end
end