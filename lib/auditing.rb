module Auditing
  
  class << self
    attr_accessor :report_on, :report_method, :serialize_type

    def configure
      yield self
      true
    end
  end
  
end

require 'auditing/base'
require 'auditing/auditor'
require 'auditing/audit_relationship'

ActiveRecord::Base.send(:extend, Auditing::Base)
ActiveRecord::Base.send(:extend, Auditing::Auditor)
ActiveRecord::Base.send(:extend, Auditing::AuditRelationship)
