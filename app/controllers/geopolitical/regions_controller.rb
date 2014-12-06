module Geopolitical
  # Main Regions Controller
  class RegionsController < GeopoliticalController
    inherit_resources
    before_filter :get_relatives, only: [:new, :edit, :create, :update]

    def collection
      @regions = Region.ordered.page(params[:page])
    end

    private

    def get_relatives
      @nations = Nation.all.map { |n| [n.name, n.id] }
    end
  end
end
