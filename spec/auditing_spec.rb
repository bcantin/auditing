require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Auditing" do
  it "responds to auditing when auditing is added to an AR object" do
    School.respond_to?(:auditing).should == true
  end
end
