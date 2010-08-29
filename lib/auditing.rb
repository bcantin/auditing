require 'auditing/auditing'
require 'auditing/auditor/audit'

ActiveRecord::Base.send(:extend, Auditing)
ActiveRecord::Base.send(:extend, Auditor::Audit)
