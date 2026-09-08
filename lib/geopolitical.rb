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

# Load Rails Engine
require 'geopolitical/engine' if Object.const_defined?('Rails')
