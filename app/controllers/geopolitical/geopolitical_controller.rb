module Geopolitical
class GeopoliticalController < ApplicationController
  # before_filter :require_

  def index
    @provinces = Province.all
    @cities = City.all
  end


end
end
