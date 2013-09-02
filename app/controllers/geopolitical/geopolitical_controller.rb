module Geopolitical
class GeopoliticalController < ApplicationController
  # before_filter :require_

  def index
    @regions = Region.all
    @cities = City.all
  end

   private

    def collection
    end
end
end
