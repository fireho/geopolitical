$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'geopolitical/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'geopolitical'
  s.version     = Geopolitical::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marcos Piccinini']
  s.email       = ['x@nofxx.com']
  s.homepage    = 'http://github.com/fireho/geopolitical'
  s.summary     = 'Geopolitical models for mongoid.'
  s.description = 'Geopolitical models for mongoid as a rails engine.'
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_dependency 'mongoid', '~> 4.0'
  s.add_dependency 'mongoid_geospatial'

  s.add_development_dependency 'rails', '>= 4.0.0'
end
