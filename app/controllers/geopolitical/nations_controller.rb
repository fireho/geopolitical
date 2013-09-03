module Geopolitical
  class NationsController < GeopoliticalController
    inherit_resources

    def collection
      @nations = Nation.ordered.page(params[:page])
    end

    private

    # def permitted_params
    #   params.permit! #require(:nation).permit!
    # end

  end
end
