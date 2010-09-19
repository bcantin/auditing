require 'spec_helper'
# require 'timecop'

describe "Auditor" do
  it 'adds the Auditable::Auditor module to the Audit class' do
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
    
    it "the first audit should be the audit we want to rollback" do
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
    
    it "the first audit after a rollback should contain the changed values" do
      @audit.rollback
      @school.reload
      @school.audits.first.old_value.should == 'PS99'
      @school.audits.first.new_value.should == 'PS118'
    end
  end
end