module Auditing
  module AuditRelationship

    # AuditRelationship creates audits for a has_many relationship.
    #
    # @examples
    #   class Company < ActiveRecord::Base
    #     has_many :phone_numbers
    #     audit_enabled
    #   end
    #   class PhoneNumber < ActiveRecord::Base
    #     belongs_to :company
    #     audit_relationship_enabled
    #   end
    #
    #   valid options include:
    #   :only => [(array of models)]
    #     an array of models to only send an audit to
    #   :except => [(array of models)]
    #     an array of models to not send an audit to
    #   :fields => [(array of field names)]
    #     an array of field names.  Each field name will be one audit item
    def audit_relationship_enabled(opts={})
      include InstanceMethods

      class_inheritable_accessor :audit_enabled_models
      class_inheritable_accessor :field_names

      self.audit_enabled_models = gather_models(opts)
      self.field_names          = gather_fields_for_auditing(opts[:fields])

      after_create   :audit_relationship_create
      before_update  :audit_relationship_update
      before_destroy :audit_relationship_destroy
    end
  
    def gather_fields_for_auditing(fields=nil)
      poly_array = []
      reflect_on_all_associations(:belongs_to).each do |assoc|
        poly_array << assoc.name if assoc.options[:polymorphic]
      end

      unless fields
        if poly_array.nil?
          return default_columns
        else
          tmp_names = default_columns
          poly_array.each do |poly|
            tmp_names = tmp_names.reject {|column| column.match(/#{poly.to_s}*/)}
          end
        end
        return tmp_names
      else
        fields.is_a?(Array) ? fields.map {|f| f.to_s} : [fields.to_s]
      end
    end

    def default_columns
      self.column_names - ["id", "created_at", "updated_at"]
    end

    def gather_models(opts={})
      if opts[:only]
        if opts[:only].is_a?(Array)
          opts[:only].map {|c| c.to_s.underscore.to_sym}
        else
          [opts[:only].to_s.underscore.to_sym]
        end
      else
        array,tmp = [], []
        reflect_on_all_associations(:belongs_to).each do |assoc|
          array << assoc.name
        end

        if opts[:except]
          if opts[:except].is_a?(Array)
            tmp = opts[:except].map {|c| c.to_s.underscore.to_sym}
          else
            tmp = [opts[:except].to_s.underscore.to_sym]
          end
        end
        array - tmp
      end
    end

    module InstanceMethods
      
      def audit_relationship_create
        audit_enabled_models.each do |model|
          return unless send(model).respond_to?('log_association_create')
          field_names.each do |field|
            field_value    = send(field)
            next unless field_value.present?
            model_instance = send(model)
            model_instance.log_association_create(self, {:field => field,
                                                         :value => field_value})
          end
        end
      end
      
      def audit_relationship_update
        if changed?
          audit_enabled_models.each do |model|
            return unless send(model).respond_to?('log_association_update')
            changes.each.select {|k,v| field_names.include?(k)}.each do |field, change|
              field_value    = send(field)
              model_instance = send(model)
              model_instance.log_association_update(self, {:field     => field,
                                                           :old_value => change[0], 
                                                           :new_value => change[1]})
            end
          end
        end
      end
      
      def audit_relationship_destroy
        audit_enabled_models.each do |model|
          return unless send(model).respond_to?('log_association_destroy')
          model_instance = send(model)
          model_instance.log_association_destroy(self)
        end
      end
      
    end

  end
end
