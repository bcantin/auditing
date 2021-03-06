module Auditing
  module Base

    # Auditing creates audit objects for a record.
    #
    # @examples
    #   class School < ActiveRecord::Base
    #      audit_enabled
    #   end
    #   class School < ActiveRecord::Base
    #     audit_enabled :fields => [:name, :established_on]
    #   end
    def audit_enabled(opts={})
      include InstanceMethods

      class_attribute :auditing_fields

      has_many :audits, :as => :auditable, :order => 'created_at DESC, id DESC'

      self.auditing_fields = gather_fields_for_auditing(opts[:fields])

      after_create :log_creation
      after_update :log_update
    end

    def gather_fields_for_auditing(fields=nil)
      return self.column_names - ["id", "created_at", "updated_at"] unless fields
      fields.is_a?(Array) ? fields.map {|f| f.to_s} : [fields.to_s]
    end

    module InstanceMethods
      
      # http://stackoverflow.com/questions/1906421/problem-saving-rails-marshal-in-sqlite3-db
      def dump_data(value)
        # ActiveSupport::Base64.encode64(Marshal.dump(value))
        Base64.encode64(Marshal.dump(value))

      end
       
      def log_creation
        add_audit(:action => 'created', :undoable => false)
      end
     
      def log_update
        if changed?
          changes.each.select {|k,v| auditing_fields.include?(k)}.each do |field, change|
            next if change[0].to_s == change[1].to_s

            add_audit(:action     => 'updated',
                      :field_name => field,
                      :old_value  => dump_data(change[0]),
                      :new_value  => dump_data(change[1]) )
          end
        end
      end

      def log_association_create(child_object, hash)
        add_audit(:action      => 'added',
                  :audit_assoc => child_object,
                  :field_name  => hash[:field],
                  :old_value   => dump_data(nil),
                  :new_value   => dump_data(hash[:value]) )
      end

      def log_association_update(child_object, hash)
        add_audit(:action      => 'updated',
                  :audit_assoc => child_object,
                  :field_name  => hash[:field],
                  :old_value   => ( dump_data(hash[:old_value]) if hash[:old_value] ) || dump_data(nil),
                  :new_value   => dump_data(hash[:new_value]) ) 
      end

      def log_association_destroy(item)
        mark_as_undoable = audits.where({:audit_assoc_id => item.id, :audit_assoc_type => item.class.to_s})
        mark_as_undoable.each do |i|
          i.update_attribute('undoable', false)
        end
        add_audit(:action => 'removed', :audit_assoc => item, :undoable => false)
      end

      def class_exists?(class_name)
        klass = Module.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
      end

      private

      def add_audit(hash={})
        unless Auditing.report_on.nil?
          if class_exists?(Auditing.report_on.to_s) && Auditing.report_on.respond_to?(Auditing.report_method.to_sym) && !Auditing.report_on.send(Auditing.report_method.to_sym).blank?
            hash[:user_id] = Auditing.report_on.send(Auditing.report_method.to_sym).id
          end
        end
        Audit.create({:auditable => self}.merge(hash))
      end

    end # Auditing::InstanceMethods

  end
end
