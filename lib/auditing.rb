require 'auditing/base'
require 'auditing/auditor'
require 'auditing/audit_relationship'

ActiveRecord::Base.send(:extend, Auditing::Base)
ActiveRecord::Base.send(:extend, Auditing::Auditor)
ActiveRecord::Base.send(:extend, Auditing::AuditRelationship)
