# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "auditing/version"

Gem::Specification.new do |s|
  s.name        = %q{auditing}
  s.version     = Auditing::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brad Cantin"]
  s.email       = ['brad.cantin@gmail.com']
  s.homepage    = 'https://github.com/bcantin/auditing'
  s.description = %q{acts_as_versioned is good. This allows an attribute level rollback instead}
  s.summary     = %q{A gem to keep track of audit hisory of a record}
  
  s.add_development_dependency "rspec"
  
  s.rubyforge_project = "auditing"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
