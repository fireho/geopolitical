# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.0.0'

group :development, :test do
  gem 'fabrication'
  gem 'faker'
  gem 'mongoid-rspec'
  gem 'rspec-rails'

  gem 'guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp', require: false
end

group :development do
  gem 'geonames_local', path: '../geonames_local', require: false if Dir.exist?('../geonames_local')
end
