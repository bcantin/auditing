require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

# Bundler::GemHelper.install_tasks

# begin
#   require 'bundler/setup'
#   Bundler::GemHelper.install_tasks
# rescue LoadError
#   puts 'although not required, bundler is recommened for running the tests'
# end

# 
# task :default => [:test]
# 
# task :test do
#   sh "bundle exec rspec spec"
# end


# require 'rake'

# begin
#   require 'bundler/setup'
#   Bundler::GemHelper.install_tasks
# rescue LoadError
#   puts 'although not required, bundler is recommened for running the tests'
# end
# 
task :default => :spec
# 
# require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--color", '--format doc']
end
# 
