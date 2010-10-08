require 'spec_helper'

describe "AuditingRelationship" do
  
  describe "has_many relationships" do
    before do
      class Company < ActiveRecord::Base
        has_many :phone_numbers, :as => :phoneable
        audit_enabled
      end
      class PhoneNumber < ActiveRecord::Base
        belongs_to :phoneable, :polymorphic => true
        audit_relationship_enabled
      end
            
      @apple = Company.create(:name => 'apple')
      @ph1   = PhoneNumber.create(:number => '1-800-apple')
    end
    
    it "should respond to audit_relationship_enabled when we add audit_relationship_enabled" do
      PhoneNumber.should respond_to(:audit_relationship_enabled)
    end
    
    it "should build an array of audit_enabled_models" do
      PhoneNumber.audit_enabled_models.should == [:phoneable]
    end
    
    it "should build an array of field_names" do
      PhoneNumber.field_names.should =~ ['number', 'extension']
    end
  end
  
end