#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include Geopolitocracy

  field :area,   type: Integer  # m2 square area
  field :geom,   type: Point,   spatial: true

  spatial_scope :geom

  attr_writer :x, :y, :z

  belongs_to :region
  belongs_to :nation
  has_many :hoods

  before_validation :set_defaults, on: [:create]

  validates :name, uniqueness: { scope: :region_id }
  validate :region_inside_nation

  def region_inside_nation
    return if !region || region.nation == nation
    errors.add(:region, 'not inside Nation')
  end

  def set_defaults
    self.nation ||= region.try(:nation)
    return unless City.where(slug: slug).first
    self.slug += "-#{region.abbr}"
    return unless City.where(slug: slug).first
    fail "Two cities with the same name in #{region}: '#{slug}'"
  end

  def phone
    self[:phone] || region.phone || nation.phone
  end

  def postal
    self[:postal] || region.postal || nation.postal
  end

  def ==(other)
    other && slug == other.slug
  end

  def <=>(other)
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
