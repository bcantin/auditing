require 'spec_helper'

describe "AuditingRelationship" do
  
  describe "adding audit_relationship_enabled on a model" do
    before do
      class Company < ActiveRecord::Base
        has_many :phone_numbers, :as => :phoneable
        audit_enabled
      end
      class PhoneNumber < ActiveRecord::Base
        belongs_to :phoneable, :polymorphic => true
        audit_relationship_enabled
      end
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
  
  describe "creating a new belongs_to object" do
    before do
      class Company < ActiveRecord::Base
        has_many :phone_numbers, :as => :phoneable
        audit_enabled
      end
      class PhoneNumber < ActiveRecord::Base
        belongs_to :phoneable, :polymorphic => true
        audit_relationship_enabled
      end
      @company = Company.create(:name => 'Apple')
    end
    
    it "should add an audit to the parent instance object (company) when we create a phone number" do
      lambda {
        @company.phone_numbers << PhoneNumber.new(:number => '1-800-orange')
        }.should change{@company.audits.count}
    end
  end
  
end