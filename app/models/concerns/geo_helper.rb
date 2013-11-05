# Geopolitical Helpers
module GeoHelper
  extend ActiveSupport::Concern

  included do
    before_validation :set_slug
  end

  def to_s
    name || slug
  end

  def set_slug
    self.slug ||= name
  end

  def slug=(txt)
    return unless txt
    self[:slug] = txt.encode(Encoding::ISO_8859_1)
      .gsub(/\s/, '-').downcase
  end

end
