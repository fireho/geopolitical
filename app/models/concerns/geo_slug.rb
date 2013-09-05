module GeoSlug
 extend ActiveSupport::Concern

  def slug= txt
    self[:slug] = txt.encode().downcase.gsub(/\s/, '-') #.gsub(/\W/, '')
  end

end
