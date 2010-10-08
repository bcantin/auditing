require 'auditing/base'
require 'auditing/auditor'

ActiveRecord::Base.send(:extend, Auditing::Base)
ActiveRecord::Base.send(:extend, Auditing::Auditor)
