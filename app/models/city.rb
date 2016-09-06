#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include Geopolitocracy

  field :area,    type: Integer # m2 square area
  field :geom,    type: Point, spatial: true
  # field :capital, type: String

  spatial_scope :geom

  attr_writer :x, :y, :z

  belongs_to :region, inverse_of: :cities
  belongs_to :nation, inverse_of: :cities
  has_many :hoods

  has_one :nation_governancy, as: :nation_capital, class_name: 'Nation'
  has_one :region_governancy, as: :region_capital, class_name: 'Region'

  before_validation :set_defaults, on: [:create]

  validates :name, uniqueness: { scope: :region_id }
  validate :region_inside_nation

  scope :population, -> { order_by(souls: -1) }

  index nation_id: 1
  index souls: -1
  index name: 1, nation_id: 1
  index({ region_id: 1 }, sparse: true)

  def region_inside_nation
    return if !region || region.nation == nation
    errors.add(:region, 'not inside Nation')
  end

  def set_defaults
    self.nation ||= region.try(:nation)
    return unless City.where(slug: slug).first
    self.slug += "-#{region.abbr}"
    return unless City.where(slug: slug).first
    raise "Two cities with the same name in #{region}: '#{slug}'"
  end

  def phone
    self[:phone] || region.phone || nation.phone
  end

  def phones
    hoods.map(&:phone)
  end

  def postal
    self[:postal] || region.postal || nation.postal
  end

  def postals
    hoods.map(&:postal)
  end

  def ==(other)
    return unless other.is_a?(City)
    other && slug == other.slug
  end

  def <=>(other)
    return unless other.is_a?(City)
    slug <=> other.slug
  end

  def with_region
    return name unless region
    "#{name}/#{region.abbr || region.name}"
  end

  def with_nation
    with_region + '/' + nation.abbr
  end

  def to_s
    with_region
  end
end
