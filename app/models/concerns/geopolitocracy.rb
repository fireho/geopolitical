# Geopolitical Helpers
module Geopolitocracy
  extend ActiveSupport::Concern

  included do
    field :name,   type: String,  localize: true
    field :abbr,   type: String
    field :gid,    type: Integer  # geonames id

    field :slug,   type: String # , default: -> { name }
    field :ascii,  type: String
    field :code,   type: String

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true

    index slug: 1
    index name: 1

    before_validation :ensure_slug
  end

  def to_s
    name || slug
  end

  def ensure_slug
    self.slug ||= name
  end

  def slug=(txt)
    return unless txt
    self[:slug] = ActiveSupport::Inflector.transliterate(txt).
                  gsub(/\s/, '-').downcase
  end

  def self.search(txt)
    where(slug: /#{ActiveSupport::Inflector.transliterate(txt)}/i)
  end
end
