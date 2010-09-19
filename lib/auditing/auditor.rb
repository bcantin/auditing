module Auditing
  module Auditor
    
    def reversable?
      %w[updated].include?(action)
    end
    
    def show_action
      action
    end
    
    def old_value
      Marshal.load(read_attribute(:old_value))
    end
    
    def new_value
      Marshal.load(read_attribute(:new_value))
    end
    
    def rollback
      return unless reversable?
      
      if association.blank?
        auditable.update_attribute(field_name.to_sym, old_value)
      else
        # TODO
        # association.class.find(association_id).update_attribute(field_name.to_sym, old_value)
      end

    end
    
  end # end Auditing::Auditor
end