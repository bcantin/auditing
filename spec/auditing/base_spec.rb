require 'spec_helper'

describe "Base" do

  describe "auditing default values" do
    before do
      class School < ActiveRecord::Base
        audit_enabled
      end
    end

    it "responds to audit_enabled when auditing is added to an AR object" do
      School.should respond_to(:audit_enabled)
    end

    it "responds to @auditing_fields" do
      School.should respond_to(:auditing_fields)
    end

    it "has default values when no fields are passed in" do
      School.stub!(:column_names).and_return(
      ["id", "name", "established_on", "created_at", "updated_at"])
      School.gather_fields_for_auditing.should == ["name", "established_on"]
    end
  end # auditing default values

  describe "audit_enabled :fields => [:foo,:bar]" do
    it "accepts a single valude as a symbol" do
      class School < ActiveRecord::Base
        audit_enabled :fields => :name
      end
      School.auditing_fields.should == ['name']
    end

    it "accepts a single value as a string" do
      class School < ActiveRecord::Base
        audit_enabled :fields => 'name'
      end
      School.auditing_fields.should == ['name']
    end

    it "accepts an array of symbols" do
      class School < ActiveRecord::Base
        audit_enabled :fields => [:name, :established_on]
      end
      School.auditing_fields.should == ['name', 'established_on']
    end

    it "accepts an array of strings" do
      class School < ActiveRecord::Base
        audit_enabled :fields => ['name', 'established_on']
      end
      School.auditing_fields.should == ['name', 'established_on']
    end
  end # auditing :fields => [:foo,:bar]

  describe "creating a new instance" do
    before do
      class School < ActiveRecord::Base
        audit_enabled
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
        audit_enabled :fields => 'name'
      end
      @school = School.create(:name => 'PS118')
    end

    it "creates an audit" do
      lambda {@school.update_attributes(:name => 'PS99')
              }.should change { Audit.count }.by(1)
    end

    it "the first audit has an action of 'updated'" do
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
        lambda {@school.update_attributes(:name => 'PS118')
                }.should_not change { Audit.count }
      end

      it "a value is not part of auditing_fields" do
        lambda {@school.update_attributes(:established_on => Time.now)
                }.should_not change { Audit.count }
      end
    end
  end # updating an existing record

  describe "belongs_to relationships" do
    before do
      class Car < ActiveRecord::Base
        audit_enabled
        belongs_to :auto_maker
      end
      class AutoMaker < ActiveRecord::Base
        has_many :cars
      end

      @car       = Car.create(:name => 'fast car')
      @automaker = AutoMaker.create(:name => 'maker of fast cars')
    end

    it "creates an audit when we add a belongs_to relationship" do
      lambda {@car.update_attributes(:auto_maker => @automaker)
              }.should change { Audit.count }.by(1)
    end

    describe "our latest audit" do
      before do
        @car.update_attributes(:auto_maker => @automaker)
      end

      it "the action should be 'updated" do
        @car.audits.first.action.should == 'updated'
      end

      it "new_value should be an id" do
        @car.audits.first.new_value.should == @automaker.id
      end

      it "should be reversable" do
        @car.audits.first.reversable?.should == true
      end
    end

    describe "updating a belongs_to" do
      before do
        @new_automaker = AutoMaker.create(:name => 'maker of safe car')
        @car.update_attributes(:auto_maker => @automaker)
      end

      it "creates an audit when we change a belongs_to relationship" do
        lambda {@car.update_attributes(:auto_maker => @new_automaker)
                }.should change { Audit.count }.by(1)
      end

      describe "our latest audit" do
        before do
          @car.update_attributes(:auto_maker => @new_automaker)
        end

        it "the action should be 'updated" do
          @car.audits.first.action.should == 'updated'
        end

        it "new_value should be an id" do
          @car.audits.first.new_value.should == @new_automaker.id
        end

        it "old_value should be an id" do
          @car.audits.first.old_value.should == @automaker.id
        end

        it "should be reversable" do
          @car.audits.first.reversable?.should == true
        end
      end
    end
  end # belongs_to relationships

  describe "text fields" do
    before do
      class Special < ActiveRecord::Base
        audit_enabled
      end
    end
    
    it "should properly work on creation" do
      long_string = 'a'
      2000.times do
        long_string << 'b'
      end
      special = Special.create(:text_field => long_string)
      special.audits.should_not be_nil
    end
    
    describe "updating a text field" do
      before do
        @long_string     = 'a'
        @new_long_string = 'c'
        2000.times do
          @long_string     << 'b'
          @new_long_string << 'd'
        end
        @special = Special.create(:text_field => @long_string)
      end
      
      it "should create an audit log when we update a text field" do
        lambda {@special.update_attributes(:text_field => @new_long_string)
                }.should change { Audit.count }.by(1)
      end
      
      it "should allow access to the old and new values" do
        @special.update_attributes(:text_field => @new_long_string)
        audit = @special.audits.first
        audit.old_value.should eql(@long_string)
        audit.new_value.should eql(@new_long_string)
      end
      
    end
    
    
  end

end
