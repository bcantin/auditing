require 'spec_helper'

describe "Auditing" do
  
  describe "auditing default values" do
    before do
      class School < ActiveRecord::Base
        auditing
      end
    end
    
    it "responds to auditing when auditing is added to an AR object" do
      School.should respond_to(:auditing)
    end
    
    it "responds to @auditing_fields" do
      School.should respond_to(:auditing_fields)
    end
    
    it "has default values when no fields are passed in" do
      School.stub!(:column_names).and_return(["id", "name", "established_on", "created_at", "updated_at"])
      School.gather_fields_for_auditing.should == ["name", "established_on"]
    end
  end # auditing default values

  describe "auditing :fields => [:foo,:bar]" do
    it "accepts a single valude as a symbol" do
      class School < ActiveRecord::Base
        auditing :fields => :name
      end
      School.auditing_fields.should == ['name']
    end
    
    it "accepts a single value as a string" do
      class School < ActiveRecord::Base
        auditing :fields => 'name'
      end
      School.auditing_fields.should == ['name']
    end
    
    it "accepts an array of symbols" do
      class School < ActiveRecord::Base
        auditing :fields => [:name, :established_on]
      end
      School.auditing_fields.should == ['name', 'established_on']
    end
    
    it "accepts an array of strings" do
      class School < ActiveRecord::Base
        auditing :fields => ['name', 'established_on']
      end
      School.auditing_fields.should == ['name', 'established_on']
    end
  end # auditing :fields => [:foo,:bar]
  
  describe "creating a new instance" do
    before do
      class School < ActiveRecord::Base
        auditing
      end
    end

    it "creates an audit" do
      lambda { School.create(:name => 'PS118') }.should change { Audit.count }.by(1)
    end
    
    it "the first audit has an action of 'created'" do
      school = School.create(:name => 'PS118')
      school.audits.first.action.should == 'created'
    end
    
    it "the first audit should not be reversable" do
      school = School.create(:name => 'PS118')
      school.audits.first.reversable?.should == false
    end
    
    it "the audit.auditable should be the object that created the audit" do
      school = School.create(:name => 'PS118')
      school.audits.first.auditable.should == school
    end
  end # creating a new instance
  
  describe "updating an existing record" do
    before do
      class School < ActiveRecord::Base
        auditing :fields => 'name'
      end
      @school = School.create(:name => 'PS118')
    end
    
    it "creates an audit" do
      lambda { @school.update_attributes(:name => 'PS99') }.should change { Audit.count }.by(1)
    end
    
    it "the first audit has an action of 'updated" do
      @school.update_attributes(:name => 'PS99')
      @school.audits.first.action.should == 'updated'
    end
    
    it "the first audit should be reversable" do
      @school.update_attributes(:name => 'PS99')
      @school.audits.first.reversable?.should == true
    end
    
    it "the first audit stored the new value" do
      @school.update_attributes(:name => 'PS99')
      @school.audits.first.new_value.should == 'PS99'
    end
    
    it "the first audit stored the old value" do
      @school.update_attributes(:name => 'PS99')
      @school.audits.first.old_value.should == 'PS118'
    end
    
    it "the audit.auditable should be the object that created the audit" do
      @school.update_attributes(:name => 'PS99')
      @school.audits.first.auditable.should == @school
    end
    
    describe "does not create an audit when" do
      it "a value did not change" do
        lambda { @school.update_attributes(:name => 'PS118') }.should_not change { Audit.count }
      end
      
      it "a value is not part of auditing_fields" do
        lambda { @school.update_attributes(:established_on => Time.now) }.should_not change { Audit.count }
      end
    end
  end # updating an existing record
  
end
