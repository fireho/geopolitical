module Geopolitical
  class CountriesController < ApplicationController
    inherit_resources

    def collection
      @countries = Country.ordered.page(params[:page])
    end

  end
end
