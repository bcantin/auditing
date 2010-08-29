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
    
    it "the initial audit has an action of 'Create'" do
      school = School.create(:name => 'PS118')
      school.audits.first.action.should == 'Create'
    end
    
    it "the initial audit should not be reversable" do
      school = School.create(:name => 'PS118')
      school.audits.first.reversable?.should == false
    end
  end
end
