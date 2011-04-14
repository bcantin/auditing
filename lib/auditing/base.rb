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
      class_inheritable_accessor :auditing_fields

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
      def log_creation
        add_audit(:action => 'created', :undoable => false)
      end

      def log_update
        if changed?
          changes.each.select {|k,v| auditing_fields.include?(k)}.each do |field, change|
            next if change[0].to_s == change[1].to_s
            add_audit(:action     => 'updated',
                      :field_name => field,
                      :old_value  => Marshal.dump(change[0]),
                      :new_value  => Marshal.dump(change[1]) )
          end
        end
      end

      def log_association_create(child_object, hash)
        add_audit(:action      => 'added',
                  :association => child_object,
                  :field_name  => hash[:field],
                  :old_value   => Marshal.dump(nil),
                  :new_value   => Marshal.dump(hash[:value].to_s) )
      end

      def log_association_update(child_object, hash)
        add_audit(:action      => 'updated',
                  :association => child_object,
                  :field_name  => hash[:field],
                  :old_value   => Marshal.dump(hash[:old_value].to_s),
                  :new_value   => Marshal.dump(hash[:new_value].to_s) ) 
      end

      def log_association_destroy(item)
        mark_as_undoable = audits.where({:association_id => item.id, :association_type => item.class.to_s})
        mark_as_undoable.each do |i|
          i.update_attribute('undoable', false)
        end
        add_audit(:action => 'removed', :association => item, :undoable => false)
      end

      def class_exists?(class_name)
        klass = Module.const_get(class_name)
        return klass.is_a?(Class)
      rescue NameError
        return false
      end

      private
        def add_audit(hash={})
          if class_exists?('User') && User.respond_to?(:current_user) && !User.current_user.blank?
            hash[:user_id] = User.current_user.id
          end
          Audit.create!({:auditable => self}.merge(hash))
        end
    end # Auditing::InstanceMethods

  end
end
