module Geopolitical
class GeopoliticalController < ActionController::Base

  layout 'geopolitical'

  def index
    @regions = Region.all
    @cities = City.all
  end


  private

  def permitted_params
    params.permit!
  end



end
end
