module Auditing
  module Auditor
    
    def reversable?
      undoable?
    end
    
    def old_value
      return nil unless read_attribute(:old_value)
      Marshal.load(read_attribute(:old_value))
    end
    
    def new_value
      return nil unless read_attribute(:new_value)
      Marshal.load(read_attribute(:new_value))
    end
    
    def rollback
      return unless reversable?
      
      if association.blank?
        auditable.update_attribute(field_name.to_sym, old_value)
      else
        association.class.find(association_id).update_attribute(field_name.to_sym, old_value)
      end

    end
    
  end # end Auditing::Auditor
end

