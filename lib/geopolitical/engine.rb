require 'mongoid_geospatial'
require 'inherited_resources'

module Geopolitical
  class Engine < ::Rails::Engine
    isolate_namespace Geopolitical
  end
end
