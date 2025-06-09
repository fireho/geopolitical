# frozen_string_literal: true

source 'https://rubygems.org'

# Loads dependencies defined in geopolitical.gemspec for the engine itself.
gemspec

# Core Rails dependency for the dummy app / engine testing.
# Version constraint should ideally match the engine's supported Rails versions.
gem 'bson', github: 'mongodb/bson-ruby', branch: 'master'
gem 'rails', '~> 8.0.0'

# Local development dependency, not required by default in the application.
# Used for populating Geonames data.

group :development, :test do
  gem 'mongoid-rspec'
  # Test suite
  gem 'fabrication' # Fixture replacement
  gem 'faker'       # For generating fake data in tests/fabricators
  gem 'rspec-rails' # For Rails integration with RSpec

  # Code quality and style
  gem 'rubocop', require: false # Static code analyzer and formatter
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Development tools
  gem 'guard', require: false # For automatically running tasks like tests or linters
  gem 'guard-rspec', require: false       # Guard plugin for RSpec
  gem 'guard-rubocop', require: false     # Guard plugin for RuboCop
  gem 'ruby-lsp', require: false          # Language Server Protocol for Ruby
  # gem 'debug', '~> 1.8' # Uncomment if you need a debugger
end

group :development do
  gem 'geonames_local', path: '../geonames_local', require: false
  # Add development-specific gems here if any are not also for test
  # For example:
  # gem 'letter_opener_web', '~> 2.0' # For previewing emails in browser
end

# NOTE: `rspec` gem is usually a dependency of `rspec-rails`
# and `guard` is a dependency for `guard-rspec` and `guard-rubocop`.
# Explicitly listing them is fine but often not strictly necessary if their dependents pull them in.
# For this refactoring, I've kept them if they were explicit, but grouped them.
# `ruby-lsp` is listed as `require: false` as it's typically a development tool, not runtime.
