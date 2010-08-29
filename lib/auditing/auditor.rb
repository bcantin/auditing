module Auditing
  module Auditor
    
    def reversable?
      %w[updated].include?(action)
    end
    
    def show_action
      action
    end
    
  end # end Auditing::Auditor
end