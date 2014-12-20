require 'mongoid'
require 'mongoid_geospatial'

module Geopolitical
  # Rails Engine
  class Engine < ::Rails::Engine
    isolate_namespace Geopolitical
  end
end
