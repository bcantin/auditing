module Auditor
  module Audit
    
    def reversable?
      return false unless undoable?
    end
    
    def show_action
      action
    end
    
  end # end Auditing::Audit
end