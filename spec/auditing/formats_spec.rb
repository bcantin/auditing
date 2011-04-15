require 'spec_helper'
require 'timecop'

describe "formats" do
  
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
  
  describe "date_fields" do
     before do
       class Special < ActiveRecord::Base
         audit_enabled
       end
     end

     it "should properly work on creation" do
       special = Special.create(:date_field => Date.today)
       special.audits.should_not be_nil
     end

     it "can update a blank date field" do
       special = Special.create
       special.date_field = Date.today
       lambda { special.save }.should change { Audit.count }.by(1)
     end

     describe "updating a date field" do
       before do
         new_time = Time.local(2008, 9, 1, 12, 0, 0)
         Timecop.freeze(new_time) # 2008-09-01 
         @special = Special.create(:date_field => Date.today)
       end
       
       it "should create an audit log when we update a text field" do
         lambda {@special.update_attributes(:date_field => Date.today + 1)
                 }.should change { Audit.count }.by(1)
         Timecop.return
       end

       it "should allow access to the old and new values" do
         @special.update_attributes(:date_field => Date.today + 1)
         audit = @special.audits.first
         audit.old_value.should eql(Date.today)
         audit.new_value.should eql(Date.today + 1)
         
         Timecop.return
       end
       
     end

   end
  
end