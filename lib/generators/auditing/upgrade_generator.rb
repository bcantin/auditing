require 'rails/generators/migration'

module Auditing
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
    
      include Rails::Generators::Migration
    
      source_root File.expand_path("../templates", __FILE__)

      def create_migration
        migration_template 'update_migration.rb', "db/migrate/update_audits.rb"
      end

      def create_initializer
        template 'auditing.rb', 'config/initializers/auditing.rb'
      end

      private

      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

    end
  end
end