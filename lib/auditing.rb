require 'auditing/auditing'
require 'auditing/auditor'

ActiveRecord::Base.send(:extend, Auditing)
ActiveRecord::Base.send(:extend, Auditing::Auditor)
