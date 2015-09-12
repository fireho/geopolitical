module Geopolitical
  # Main Geopolitical Controller
  class GeopoliticalController < ActionController::Base
    layout 'geopolitical'

    def index
      @regions = Region.all
      @cities = City.all
    end

    private

    def permitted_params
      # params.permit(:name, :slug)
    end
  end
end
