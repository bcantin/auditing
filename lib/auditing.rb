require 'auditing/auditing'

ActiveRecord::Base.send(:extend, Auditing)