# auditing

Auditing is a simple way to track and rollback changes to a record.

[![Build Status](http://travis-ci.org/bcantin/auditing.png)](http://travis-ci.org/bcantin/auditing)

## Sample Project

https://github.com/bcantin/auditing_project
  
## Installation

    gem install auditing
  
There is a handy installer in the gem now. To see what it will do
  
    rails g auditing:install --help
  
and, of course, to use it

    rails g auditing:install
    rake db:migrate
    
If you want to track the user, uncomment the t.integer :user_id above.  See the Tracking Users section below.


## Upgrading to 1.4.0

New installs will not need to do this.  Anyone that is using 1.2.X and below should upgrade

    gem update auditing
    # ... updates happen
    rails g auditing:upgrade
    rake db:migrate
    
This will create a new migration to update the :old_value and :new_value attribute from STRING to TEXT
It will also create an initializer (see Tracking Users section below)


## Current master branch is in review for rails 3.1.x 

Please note that the current master branch is being updated to work with
Rails 3.1.x  The latest release of auditing should work with rails 3.0.x  As
always, please report any bugs

## Basic Usage

To add auditing to all attributes on a model, simply add auditing to the model.

    class School < ActiveRecord::Base
      audit_enabled
    end

If you want more control over which attributes are audited, you can define them
by supplying a fields hash

    class School < ActiveRecord::Base
      audit_enabled :fields => [:name, :established_on]
    end
  
Auditing will not track "id", "created_at", or "updated_at" by default

## belongs_to relationships

Auditing a belongs_to relationship works by keeping track of the foreign_id attribute. You do
not need to add anything to the foreign model.

## has_many relationships

You may have the need to keep track of a has_many relationship.  To accomplish this, we have
to enable a similar type of auditing on the other model(s)

    class Company < ActiveRecord::Base
      has_many :phone_numbers
      audit_enabled
    end
    class PhoneNumber < ActiveRecord::Base
      belongs_to :company
      audit_relationship_enabled
    end

As above, you can supply a :fields hash of which attributes will be logged.
If your relationship is polymorphic, you can supply an array of classes
that you only want to log.

    audit_relationship_enabled :only => [Company, Person]

## Tracking Users

To track which logged in users have made the changes, you will need to have a 
user_id column in your audits table.  If you did not add it when you created
the audits table, you can add it in another migration

    add_column :audits, :user_id, :integer

To let the auditing gem know which model to attribute the changes to, you will 
need to do some minor setup.  Edit the config/initializers/auditing.rb file 
created during the installation.  If you do not have that file, it should 
look like this...

    Auditing.configure do |config|
      config.report_on      = nil # User
      config.report_method  = nil # 'current_user'
    end
        

You will need to set the config.report_on to the model you are using.  Most 
applications use a model called User and a method called 'current_user'. If 
this is your case, then your config file should be updated to look like this...

    Auditing.configure do |config|
      config.report_on      = User
      config.report_method  = 'current_user'
    end

If your application uses something else, say a model called Member, and you 
have a method to get the logged in member called 'my_awesome_member' then your
config file should be updated to look like this...

    Auditing.configure do |config|
      config.report_on      = Member
      config.report_method  = 'my_awesome_member'
    end

You will need to add the relationship to the Audit class and to your User / Member /
(Insert your custom model here)

    class Audit < ActiveRecord::Base
      belongs_to :user
    end

    class User < ActiveRecord::Base
      has_many :audits
    end

You can alter the suggested implementation below to suite your needs.  I am showing
a model named User and a method called current_user.  



Your User class should respond to a class method called current_user 
and current_user= (some authentication systems do this, others do not).

Here is a suggested method

    class User < ActiveRecord::Base
  
      def self.current_user=(current_user)
        @current_user = current_user
      end
  
      def self.current_user
        @current_user
      end
  
    end

Your ApplicationController should also set the current_user so the auditing gem can 
get the current_user properly

    class ApplicationController < ActionController::Base
      before_filter :set_current_user
      after_filter  :unset_current_user
  
      private
  
      def set_current_user
        User.current_user = current_user
      end
  
      def unset_current_user
        User.current_user = nil
      end
    end
  
## Testing

To run the tests, first clone this repo, then

    cd auditing
    bundle
    rake

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in 
  a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2012 Brad Cantin. See LICENSE for details.
