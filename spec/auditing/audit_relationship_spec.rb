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
  
    describe "creating a new belongs_to object" do
      before do
        @company = Company.create(:name => 'Apple')
      end
    
      it "should add an audit to the parent instance object (company) when we create a phone number" do
        lambda {
          @company.phone_numbers << PhoneNumber.new(:number => '1-800-orange')
          }.should change{@company.audits.count}
      end
    
      it "should add an audit for each field" do
        lambda {
          @company.phone_numbers << PhoneNumber.new(:number => '1-800-orange', :extension => '1')
          }.should change{@company.audits.count}.by(2)
      end
  
      describe "updating an existing belongs_to object" do
        before do
          @ph = PhoneNumber.new(:number => '1-800-orange', :extension => '1')
          @company.phone_numbers << @ph
        end
    
        it "should add an audit to the parent instance when we update a phone number" do
          lambda {@ph.update_attributes(:number => '1-800-apple')}.should change{@company.audits.count}
        end
        
        describe "deleting a child_object" do
          it "should add an audit to the parent instance when we delete a phone number" do
            lambda {PhoneNumber.destroy(@ph)}.should change{@company.audits.count}
          end
        end
      end
    end
  end
end