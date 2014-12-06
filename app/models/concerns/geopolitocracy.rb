# Geopolitical Helpers
module Geopolitocracy
  extend ActiveSupport::Concern

  included do
    field :name,   type: String,  localize: true

    field :gid,    type: Integer  # geonames id

    field :slug,  type: String
    field :ascii,  type: String

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
