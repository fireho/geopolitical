module Geopolitical
  class RegionsController < GeopoliticalController
   # inherit_resources
    before_filter :get_relatives, :only => [:new, :edit]

    def collection
      @regions = Region.ordered.page(params[:page])
    end

    private

    def get_relatives
      @nations = Nation.all
    end

  end
end
