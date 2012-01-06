require 'spec_helper'

describe "Auditor" do

  before do
    Audit.destroy_all
  end

  it 'adds the Auditing::Auditor module to the Audit class' do
    Audit.new.should respond_to(:rollback)
  end

  it "can save an audit that has no data" do
    a = Audit.create
    a.should be_valid
  end

  it "can add an audit thru the association" do
    class School < ActiveRecord::Base
      has_many :audits, :as => :auditable #, :order => 'created_at DESC, id DESC'
    end
    school = School.create!(:name => 'PS118')
    school.audits.create!(:action => 'created', :undoable => false)
    Audit.count.should eql(1)
  end

  it "can save an using audit_enabled" do
    class School < ActiveRecord::Base
      audit_enabled
    end
    school = School.create!(:name => 'PS118')
    Audit.count.should eql(1)
  end

  it "can update" do
    class School < ActiveRecord::Base
      audit_enabled
    end
    school = School.create(:name => 'PS118')
    school.update_attributes(:name => 'PS99')

    Audit.count.should eql(2)
    school.audits.count.should eql(2)
    
    audit = school.audits.first
    audit.action.should      == 'updated'
    audit.new_value.should   == 'PS99'
    audit.old_value.should   == 'PS118'
    audit.audit_assoc.should be_nil
  end

  describe "#rollback" do
    before do
      class School < ActiveRecord::Base
        audit_enabled
      end
      @school = School.create(:name => 'PS118')
      @school.update_attributes(:name => 'PS99')
      @audit = @school.audits.first
    end

    it "the latest audit should be the audit we want to rollback" do
      @audit.action.should      == 'updated'
      @audit.new_value.should   == 'PS99'
      @audit.old_value.should   == 'PS118'
      @audit.audit_assoc.should == nil
    end

    it "performs the rollback" do
      @audit.rollback
      @school.reload
      @school.name.should == 'PS118'
    end

    it "creates an audit when a rollback is performed" do
      lambda { @audit.rollback }.should change { Audit.count }.by(1)
    end

    it "the latest audit after a rollback should contain the changed values" do
      @audit.rollback
      @school.reload
      @school.audits.first.old_value.should == 'PS99'
      @school.audits.first.new_value.should == 'PS118'
    end
  end

  describe "#rollback belongs_to attribute" do
    before do
      class Car < ActiveRecord::Base
        audit_enabled
        belongs_to :auto_maker
      end
      class AutoMaker < ActiveRecord::Base
        has_many :cars
      end
      @automaker     = AutoMaker.create(:name => 'maker of fast cars')
      @new_automaker = AutoMaker.create(:name => 'maker of safe cars')

      @car = Car.create(:name => 'fast car', :auto_maker => @automaker)
      @car.update_attributes(:auto_maker => @new_automaker)
      @audit = @car.audits.first
    end

    it "the latest audit should be the audit we want to rollback" do
      @audit.action.should      == 'updated'
      @audit.new_value.should   == @new_automaker.id
      @audit.old_value.should   == @automaker.id
      @audit.audit_assoc.should == nil
      @car.auto_maker.should    == @new_automaker
    end

    it "performs the rollback" do
      @audit.rollback
      @car.reload
      @car.auto_maker.should == @automaker
    end

    it "creates an audit when a rollback is performed" do
      lambda { @audit.rollback }.should change { Audit.count }.by(1)
    end

    it "the latest audit after a rollback should contain the changed values" do
      @audit.rollback
      @car.reload
      @car.audits.first.old_value.should == @new_automaker.id
      @car.audits.first.new_value.should == @automaker.id
    end
  end

  describe "rollback has_many attributes" do
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
      @ph      = PhoneNumber.new(:number => '1-800-orange')
      @company.phone_numbers << @ph
      @ph.update_attributes(:number => '1-800-call-apple')
      @audit = @company.audits.first
    end

    it "the latest audit should be the audit we want to rollback" do
      @audit.action.should      == 'updated'
      @audit.new_value.should   == '1-800-call-apple'
      @audit.old_value.should   == '1-800-orange'
      @audit.audit_assoc.should == @ph
    end

    it "performs the rollback" do
      @audit.rollback
      @company.reload
      @company.phone_numbers.first.number.should == '1-800-orange'
    end

    it "creates an audit when a rollback is performed" do
      lambda { @audit.rollback }.should change { Audit.count }.by(1)
    end

    it "the latest audit after a rollback should contain the changed values" do
      @audit.rollback
      @company.reload
      @company.audits.first.old_value.should == '1-800-call-apple'
      @company.audits.first.new_value.should == '1-800-orange'
    end
  end
end
