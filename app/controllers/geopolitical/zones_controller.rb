module Geopolitical
  # Main Zones Controller
  class ZonesController < GeopoliticalController
    inherit_resources

    def collection
      @zones = Zone.ordered.page(params[:page])
    end

    private

  end

end
