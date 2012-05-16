module Geopolitical
  class HoodsController < ApplicationController
    inherit_resources
    # belongs_to :city
    # respond_to :html, :xml, :json

    def collection
      @hoods = Hood.ordered.search(params[:search], params[:page])
    end

  end
end
