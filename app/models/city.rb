#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include GeoHelper

  field :gid,    type: Integer
  field :zip,    type: String
  field :slug,   type: String
  field :name,   type: String,  localize: true
  field :ascii,  type: String
  field :area,   type: Integer
  field :souls,  type: Integer
  field :geom,   type: Point,   spatial: true

  spatial_scope :geom

  attr_writer :x, :y, :z

  belongs_to :region
  belongs_to :nation
  has_many :hoods

  index name: 1

  scope :ordered, -> { order_by(name: 1) }

  validates :slug, presence: true, uniqueness: true
  validates :name, uniqueness: { scope: :region_id }

  # scope :close_to, GeoHelper::CLOSE

  before_validation :set_defaults

  def set_defaults
    self.nation ||= region.try(:nation)
  end

  def abbr
    return unless region || nation
    region ? region.abbr : nation.abbr
  end

  def self.search(txt)
    where(slug: /#{txt}/i)
  end

  def <=>(other)
    slug <=> other.slug
  end

end
