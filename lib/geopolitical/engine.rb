# frozen_string_literal: true

require 'mongoid'
require 'mongoid/geospatial'

module Geopolitical
  # Rails Engine
  class Engine < ::Rails::Engine
    isolate_namespace Geopolitical
  end
end
