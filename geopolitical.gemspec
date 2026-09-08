# frozen_string_literal: true

require_relative 'lib/geopolitical/version'

Gem::Specification.new do |s|
  s.name        = 'geopolitical'
  s.version     = Geopolitical::VERSION
  s.authors     = ['Marcos Piccinini']
  s.email       = ['x@nofxx.com']
  s.homepage    = 'https://github.com/fireho/geopolitical'
  s.summary     = 'Nation, Region, City and Hood models for Mongoid.'
  s.description = 'The whole planet as four Mongoid models: hierarchy, i18n names, ' \
                  'unicode-safe slugs, geo queries, phone/postal fallbacks and an admin engine.'
  s.license     = 'MIT'
  s.metadata    = { 'rubygems_mfa_required' => 'true', 'source_code_uri' => s.homepage }

  # Ship the engine (app, config, lib) and the docs. No specs, no dev tooling.
  s.files = `git ls-files -z`.split("\x0")
            .grep(%r{^(app|config|lib)/|^(README\.md|CHANGELOG\.md|MIT-LICENSE|geopolitical\.gemspec)$})
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.2.0'

  s.add_dependency 'haml', '>= 6.0'
  s.add_dependency 'mongoid', '>= 8.0.0'
  s.add_dependency 'mongoid-geospatial', '>= 4.0.0'
end
