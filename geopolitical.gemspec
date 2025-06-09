# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'geopolitical/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'geopolitical'
  s.version     = Geopolitical::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marcos Piccinini']
  s.email       = ['x@nofxx.com'] # Consider updating if this is a placeholder
  s.homepage    = 'https://github.com/fireho/geopolitical' # Ensured HTTPS
  s.summary     = 'Geopolitical models (Nation, Region, City, Hood) for Mongoid-based Rails applications.'
  s.description = <<~DESC
    Provides a set of Mongoid models for managing geopolitical entities such as nations,
    regions, cities, and neighborhoods. Includes common attributes, relationships,
    geospatial capabilities, and helper methods. Designed as a Rails engine for easy integration.
  DESC
  s.license     = 'MIT'

  # Specify which files should be added to the gem.
  # `git ls-files` is a common approach but ensure your .gitignore is effective.
  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) # Exclude test/spec/features
  end
  s.bindir        = "exe" # If you have executables
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  # Specify a minimum Ruby version requirement
  s.required_ruby_version = '>= 3.0.0' # Or your actual minimum supported version

  # Runtime dependencies:
  # These are required for the gem to function.
  s.add_dependency 'mongoid', '>= 8.0.0'
  s.add_dependency 'mongoid-geospatial', '>= 4.0.0' # More specific versioning
end
