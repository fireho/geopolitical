module Geopolitical
  class ProvincesController < GeopoliticalController
   # inherit_resources
    before_filter :get_relatives, :only => [:new, :edit]

    def collection
      @provinces = Province.ordered.page(params[:page])
    end

    private

    def get_relatives
      @countries = Country.all
    end
  end
end
