module Geopolitical
  class CitiesController < ApplicationController
    # allow  "admin"
    before_filter :load_relatives, :only => [:new, :edit, :create, :update]

    def collection
      City.ordered.search(params[:search], params[:page]) # @cc.country.cities
    end

    private

    def load_marker
    end

    def load_map
    end

    def load_relatives
      @provinces = Province.only(:name).map {|e| [e.name,e.id]}
    end
  end
end
