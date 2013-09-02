module Geopolitical
  class CountriesController < GeopoliticalController

    def collection
      @countries = Country.ordered.page(params[:page])
    end

  end
end
