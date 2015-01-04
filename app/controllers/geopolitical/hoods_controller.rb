module Geopolitical
  # Hoods Main Public Interface
  class HoodsController < GeopoliticalController
    # belongs_to :city
    # respond_to :html, :xml, :json
    before_filter :load_relatives, only: [:new, :edit, :create, :update]

    def collection
      @hoods = Hood.ordered.page(params[:page])
    end

    private

    def load_relatives
      @cities = City.only(:name).map { |e| [e.name, e.id] }
    end
  end
end
