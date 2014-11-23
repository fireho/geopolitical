require 'mongoid'
require 'mongoid_geospatial'
require 'inherited_resources'

module Geopolitical
  # Rails Engine
  class Engine < ::Rails::Engine
    isolate_namespace Geopolitical
  end
end
