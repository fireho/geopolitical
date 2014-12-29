# Geopolitical Helpers
module Geopolitocracy
  extend ActiveSupport::Concern

  included do
    field :gid,    type: Integer # geonames id

    field :name,   type: String, localize: true
    field :abbr,   type: String
    field :nick,   type: String

    field :souls,  type: Integer  # Population

    field :ascii,  type: String
    field :code,   type: String
    field :slug,   type: String  # , default: -> { name }

    field :postal,  type: String  # , default: -> { name }
    field :phone,   type: String  # , default: -> { name }

    alias_method :population, :souls
    alias_method :iso_3166_2, :code

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true

    index slug: 1
    index name: 1

    before_validation :ensure_slug

    scope :ordered, -> { order_by(name: 1) }

    def self.search(txt)
      txt.gsub!(/\s/, '-')
      where(slug: /^#{ActiveSupport::Inflector.transliterate(txt)}/i)
    end
  end

  def ensure_slug
    self.slug ||= name
  end

  def slug=(txt)
    return unless txt
    self[:slug] = ActiveSupport::Inflector.transliterate(txt)
                  .gsub(/\s/, '-').downcase
  end

  def to_s
    name || slug
  end
end
