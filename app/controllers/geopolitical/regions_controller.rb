module Geopolitical
  # Main Regions Controller
  class RegionsController < GeopoliticalController
    before_filter :set_nations, only: [:new, :edit, :create, :update]

    def collection
      @regions = Region.ordered.page(params[:page])
    end

    private

    def set_nations
      @nations = Nation.all.map { |n| [n.name, n.id] }
    end
  end
end
