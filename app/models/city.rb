#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include Geopolitocracy

  field :zip,    type: String
  field :area,   type: Integer  # m2 square area
  field :souls,  type: Integer  # Population
  field :geom,   type: Point,   spatial: true

  alias_method :population, :souls

  spatial_scope :geom

  attr_writer :x, :y, :z

  belongs_to :region
  belongs_to :nation
  has_many :hoods

  validates :name, uniqueness: { scope: :region_id }

  before_validation :set_defaults, on: [:create]

  def set_defaults
    self.nation ||= region.try(:nation)
    return unless City.where(slug: slug).first
    self.slug += "-#{region.abbr}"
    return unless City.where(slug: slug).first
    fail "Two cities with the same name in #{region}: '#{slug}'"
  end

  def abbr
    return unless region || nation
    region ? region.abbr : nation.abbr
  end

  def ==(other)
    other && slug == other.slug
  end

  def <=>(other)
    slug <=> other.slug
  end
end
