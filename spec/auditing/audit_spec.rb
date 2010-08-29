require 'spec_helper'
# require 'timecop'

describe "Audit" do
  it 'adds the Auditable::Audit module to the Audit class' do
    Audit.new.should respond_to(:show_action)
  end
end