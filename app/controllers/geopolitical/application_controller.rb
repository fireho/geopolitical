# frozen_string_literal: true

module Geopolitical
  class ApplicationController < Geopolitical.parent_controller.constantize
    protect_from_forgery with: :exception
    layout 'geopolitical'
  end
end
