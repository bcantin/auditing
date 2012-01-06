$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'auditing'
require 'rspec'
require 'timecop'

# our test database
TEST_DB = File.join(File.dirname(__FILE__), '..', 'test.sqlite3')
File.unlink(TEST_DB) if File.exist?(TEST_DB)
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3", 
  :database => TEST_DB
)

# our schema
load(File.dirname(__FILE__) + '/schema.rb')

Auditing.configure do |config|
  config.report_on      = nil
  config.report_method  = nil
end

class Audit < ActiveRecord::Base
  include Auditing::Auditor
  belongs_to :auditable,   :polymorphic => true
  belongs_to :audit_assoc, :polymorphic => true
end
