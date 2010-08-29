module Auditing

  # Auditing creates audit objects for a record.
  #
  # @examples
  #   class School < ActiveRecord::Base
  #      auditing
  #   end
  #   class School < ActiveRecord::Base
  #     auditing :fields => [:name, :established_on]
  #   end
  def auditing(opts={})
    include InstanceMethods
    class_inheritable_accessor :auditing_fields

    has_many :audits, :as => :auditable, :order => 'created_at DESC, id DESC'

    self.auditing_fields = gather_fields_for_auditing(opts[:fields])
    
    after_create :log_create
  end

  def gather_fields_for_auditing(fields=nil)
    return self.column_names - ["id", "created_at", "updated_at"] unless fields
    fields.is_a?(Array) ? fields.map {|f| f.to_s} : [fields.to_s]
  end

  module InstanceMethods
    def log_create
      Audit.create!(:auditable => self, :action => 'Create', :undoable => false)
    end
  end # Auditing::InstanceMethods

end
