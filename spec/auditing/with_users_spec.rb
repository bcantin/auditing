require 'spec_helper'

describe "auditing with users" do

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