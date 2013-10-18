module Geopolitical
  # Cities Public Controller
  class CitiesController < GeopoliticalController
    # allow  "admin"
    inherit_resources
    before_filter :load_relatives, only: [:new, :edit, :create, :update]

    def collection
      @cities = City.ordered.search(params[:search]).page(params[:page])
    end

    private

    def load_marker
    end

    def load_map
    end

    def load_relatives
      @regions = Region.only(:name).map { |e| [e.name, e.id] }
    end

  end

end
