# require 'bundler'
# Bundler::GemHelper.install_tasks

begin
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'although not required, bundler is recommened for running the tests'
end

# 
# task :default => [:test]
# 
# task :test do
#   sh "bundle exec rspec spec"
# end

# require 'rake/testtask'

# Rake::TestTask.new do |t|
#   t.libs << 'spec'
# end

desc "Run tests"
task :default => :spec

# task :default => :test


# require 'rake'

# begin
#   require 'bundler/setup'
#   Bundler::GemHelper.install_tasks
# rescue LoadError
#   puts 'although not required, bundler is recommened for running the tests'
# end
# 
# task :default => :spec
# 
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--color", '--format doc']
end
# 
