# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'

#
# Geopolitical
#
# Nations, Regions, Cities and Hoods
#
module Geopolitical
  # Controller the engine's controllers inherit from. The admin UI has no
  # authentication of its own — point this at a controller of yours that does:
  #
  #   # config/initializers/geopolitical.rb
  #   Geopolitical.parent_controller = 'Admin::BaseController'
  #
  mattr_accessor :parent_controller, default: 'ActionController::Base'
end

if Object.const_defined?('Rails')
  require 'geopolitical/engine'
else
  require 'mongoid'
  require 'mongoid/geospatial'
  require_relative '../app/models/concerns/geopolitocracy'
  require_relative '../app/models/nation'
  require_relative '../app/models/region'
  require_relative '../app/models/city'
  require_relative '../app/models/hood'
end
