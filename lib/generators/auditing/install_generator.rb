require 'rails/generators/migration'

module Auditing
  module Generators
    class InstallGenerator < Rails::Generators::Base
    
      include Rails::Generators::Migration
    
      source_root File.expand_path("../templates", __FILE__)

      def create_controller_files
        template 'audits_controller.rb', 'app/controllers/audits_controller.rb'
      end

      def create_helper_files
        template 'audits_helper.rb', 'app/helpers/audits_helper.rb'
      end

      def create_model_files
        template 'audit.rb', 'app/models/audit.rb'
      end

      def create_view_files
        template 'index.html.erb', 'app/views/audits/index.html.erb'
      end

      def create_routes
        route "match ':resource/:id/audits' => 'audits#index', :as => 'audits'"
        route "match 'audit/rollback/:id'   => 'audits#rollback', :as => 'audit_rollback'"
      end

      def create_migration
        migration_template 'migration.rb', "db/migrate/create_audits.rb"
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