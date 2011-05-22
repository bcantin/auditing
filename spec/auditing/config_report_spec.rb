require 'spec_helper'

describe "auditing configuration" do

  describe ":report_on => User; :report_method => 'current_user'" do
    before do
      class School < ActiveRecord::Base
        audit_enabled
      end
    
      class User < ActiveRecord::Base
        def self.current_user=(user)
          @current_user = user
        end
        def self.current_user
          @current_user
        end
      end
    
      Auditing.configure do |config|
        config.report_on     = User
        config.report_method = 'current_user'
      end
    
      @user1 = User.create(:email=>'foo@example.com')
      @user2 = User.create(:email=>'bar@example.com')
    end
  
    it "adds the user to the audit" do
      User.current_user = @user1
      school = School.create(:name => 'PS118')
      a = school.audits.first
      a.user_id.should == @user1.id
      User.current_user = nil
    end
  
    it "does not add the user to the audit if User.current_user is not set" do
      school = School.create(:name => 'PS118')
      a = school.audits.first
      a.user_id.should == nil
    end
  end
  
  describe ":report_on => Member; :report_method => 'current_member'" do
    before do
      class School < ActiveRecord::Base
        audit_enabled
      end
    
      class Member < ActiveRecord::Base
        def self.current_member=(member)
          @current_member = member
        end
        def self.current_member
          @current_member
        end
      end
    
      Auditing.configure do |config|
        config.report_on     = Member
        config.report_method = 'current_member'
      end
    
      @member1 = Member.create(:member_name=>'foo_dude')
      @member2 = Member.create(:member_name=>'bar_dude')
    end
  
    it "adds the member to the audit" do
      Member.current_member = @member1
      school = School.create(:name => 'PS118')
      a = school.audits.first
      a.user_id.should == @member1.id
      Member.current_member = nil
    end
  
    it "does not add the member to the audit if Member.current_member is not set" do
      school = School.create(:name => 'PS118')
      a = school.audits.first
      a.user_id.should == nil
    end
  end
end