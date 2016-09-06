module Geopolitical
  # Nations Public Controller
  class NationsController < GeopoliticalController
    def collection
      @nations = Nation.ordered
    end

    # private
    # def permitted_params
    #   params.permit! #require(:nation).permit!
    # end
  end
end
