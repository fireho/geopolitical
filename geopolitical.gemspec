$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "geopolitical/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "geopolitical"
  s.version     = Geopolitical::VERSION
  s.authors     = ["Marcos Piccinini"]
  s.email       = ["x@nofxx.com"]
  s.homepage    = "http://github.com/nofxx/geopolitical"
  s.summary     = "Geopolitical models for mongoid."
  s.description = "Geopolitical models for mongoid as a rails engine."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "mongoid"
  s.add_dependency "mongoid_geospatial"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
end
