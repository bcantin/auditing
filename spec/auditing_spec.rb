require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Auditing" do
  
  it "responds to auditing when auditing is added to an AR object" do
    class School < ActiveRecord::Base
      auditing
    end
    School.respond_to?(:auditing).should == true
  end
  
  describe "auditing default values" do
    before(:each) do
      class School < ActiveRecord::Base
        auditing
      end
    end
    
    it "responds to @auditing_fields" do
      School.respond_to?(:auditing_fields).should == true
    end
    
    it "has default values when no fields are passed in" do
      School.stub!(:column_names).and_return(["id", "name", "established_on", "created_at", "updated_at"])
      School.gather_fields_for_auditing.should == ["name", "established_on"]
    end
  end

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
  end
end
