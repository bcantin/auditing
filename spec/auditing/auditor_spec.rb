require 'spec_helper'

describe "Auditor" do
  it 'adds the Auditing::Auditor module to the Audit class' do
    Audit.new.should respond_to(:show_action)
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
      @audit.association.should == nil
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
      @audit.association.should == nil
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
end