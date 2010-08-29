require 'spec_helper'
# require 'timecop'

describe "Auditor" do
  it 'adds the Auditable::Auditor module to the Audit class' do
    Audit.new.should respond_to(:show_action)
  end
end