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
      class_inheritable_accessor :audit_enabled_models
      class_inheritable_accessor :field_names
      
      self.audit_enabled_models = gather_models(opts)
      self.field_names          = gather_fields_for_auditing(opts[:fields])
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
            tmp_names = tmp_names.select {|column| !column.match(/#{poly.to_s}*/)}
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
    
    
  end
end