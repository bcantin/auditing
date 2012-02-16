module Auditing
  module Auditor
    
    def reversable?
      undoable?
    end
    
    def old_value
      attributes = attributes_before_type_cast
      if attributes["old_value"]
        # Marshal.load( ActiveSupport::Base64.decode64( read_attribute(:old_value) ) )
        Marshal.load( Base64.decode64( read_attribute(:old_value) ) )

      else
        nil
      end

      # return nil unless read_attribute(:old_value)
      # Marshal.load( ActiveSupport::Base64.decode64( read_attribute(:old_value) ) )
    end
    
    def new_value
      attributes = attributes_before_type_cast
      if attributes["new_value"]
        # Marshal.load( ActiveSupport::Base64.decode64( read_attribute(:new_value) ) )
        Marshal.load( Base64.decode64( read_attribute(:new_value) ) )

      else
        nil
      end
      # return nil unless read_attribute(:new_value)
      # Marshal.load( ActiveSupport::Base64.decode64( read_attribute(:new_value) ) )
    end
    
    def rollback
      return unless reversable?
      
      if audit_assoc.blank?
        auditable.update_attribute(field_name.to_sym, old_value)
      else
        audit_assoc.class.find(audit_assoc_id).update_attribute(field_name.to_sym, old_value)
      end

    end
    
  end # end Auditing::Auditor
end

