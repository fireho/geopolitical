#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include Geopolitocracy

  field :area,    type: Integer # m2 square area
  field :geom,    type: Point, spatial: true
  field :rbbr,    type: String, as: :region_abbr

  spatial_scope :geom

  belongs_to :region, inverse_of: :cities, optional: true
  belongs_to :nation, inverse_of: :cities
  has_many :hoods

  has_one :nation_governancy, as: :nation_capital, class_name: 'Nation'
  has_one :region_governancy, as: :region_capital, class_name: 'Region'

  before_validation :set_defaults, on: [:create]

  validates :name, uniqueness: { scope: :region_id }
  validate :region_inside_nation

  scope :population, -> { order_by(souls: -1) }

  index({ slug: 1 }, unique: true)
  index({ name: 1, nation_id: 1 })
  index({ nation_id: 1 })
  index({ region_id: 1 }, sparse: true)
  index({ souls: -1 })

  def region_inside_nation
    return if !region || region.nation == nation
    errors.add(:region, 'not inside Nation')
  end

  def set_defaults
    self.nation ||= region&.nation
    self.rbbr ||= region&.abbr || region&.slug
    self.slug += "-#{rbbr}" if rbbr && !slug.include?(rbbr)
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

  def with_region(separator = '/')
    return name unless region_abbr
    "#{name}#{separator}#{region_abbr}"
  end

  def with_nation(separator = '/')
    with_region(separator) + "#{separator}#{nation.abbr}"
  end

  def to_s
    with_region
  end
end
