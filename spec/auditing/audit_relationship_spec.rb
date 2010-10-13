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

    describe "creating a new has_many object" do
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

      describe "updating an existing has_many object" do
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
          
          it "should mark previous audits involving this has_many object so they can not be reversed" do
            ph_id    = @ph.id
            ph_assoc = @ph.class.to_s
            
            PhoneNumber.destroy(@ph)
            ph_audits = @company.audits.where({:association_id => ph_id, :association_type => ph_assoc})
            collection = ph_audits.collect(&:undoable)
            collection.uniq.should == [false]
          end
        end
      end
    end
  end
  
  describe "has_many :through" do
    before do
      class Company < ActiveRecord::Base
        has_many :employments
        has_many :people, :through => :employments
        audit_enabled
      end
      class Person < ActiveRecord::Base
        has_many :employments
        has_many :companies, :through => :employments
        audit_enabled
      end
      class Employment < ActiveRecord::Base
        belongs_to :person
        belongs_to :company
        audit_relationship_enabled :fields => :start_date
      end
      @company = Company.create(:name => 'Apple')
      @person  = Person.create(:first_name => 'Steve')
    end
    
    it "adds an audit to the company" do
      lambda {Employment.create(:person     => @person, 
                                :company    => @company, 
                                :start_date => 'yesterdayish')
      }.should change{@company.audits.count}.by(1)
    end
    it "adds an audit to the person" do
      lambda {Employment.create(:person     => @person, 
                                :company    => @company, 
                                :start_date => 'yesterdayish')
      }.should change{@person.audits.count}.by(1)
    end
    it "increases the total audit count" do
      lambda {Employment.create(:person     => @person, 
                                :company    => @company, 
                                :start_date => 'yesterdayish')
      }.should change{Audit.count}.by(2)
    end
    
    describe "updating" do
      before do
        @emp = Employment.create(:person     => @person, 
                                 :company    => @company, 
                                 :start_date => 'yesterdayish')
      end
      it "increases the audit log for the company" do
        lambda {@emp.update_attribute(:start_date, 'today')
        }.should change{@company.audits.count}.by(1)
      end
      it "increases the audit log for the person" do
        lambda {@emp.update_attribute(:start_date, 'today')
        }.should change{@person.audits.count}.by(1)
      end
      it "increases the total audit count" do
        lambda {@emp.update_attribute(:start_date, 'today')
        }.should change{Audit.count}.by(2)
      end
    end

  end
    
end
