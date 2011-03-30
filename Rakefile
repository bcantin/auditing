require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test]

task :test do
  sh "bundle exec rspec spec"
end