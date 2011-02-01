$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'auditing'
require 'rspec'

# our test database
TEST_DB = File.join(File.dirname(__FILE__), '..', 'test.sqlite3')
File.unlink(TEST_DB) if File.exist?(TEST_DB)
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3", 
  :database => TEST_DB
)

# our schema
load(File.dirname(__FILE__) + '/schema.rb')

class Audit < ActiveRecord::Base
  include Auditing::Auditor
  belongs_to :auditable,   :polymorphic => true
  belongs_to :association, :polymorphic => true
end

class User < ActiveRecord::Base
end