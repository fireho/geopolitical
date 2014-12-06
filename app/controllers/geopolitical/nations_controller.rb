module Geopolitical
  # Nations Public Controller
  class NationsController < GeopoliticalController
    inherit_resources

    def collection
      @nations = Nation.ordered
    end

    private

    # def permitted_params
    #   params.permit! #require(:nation).permit!
    # end
  end
end
