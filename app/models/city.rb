class City
  include Mongoid::Document
  include Mongoid::Geospatial

  # include GeoHelper

  field :slug
  field :name
  field :area
  field :gid,   type: Integer
  field :zip,   type: Integer
  field :souls, type: Integer
  field :geom,  type: Point, spatial: true

  # index [[ :geom, Mongo::GEO2D ]], min: 200, max: 200
  index :slug
  spatial_index :geom

  belongs_to :province
  belongs_to :country, index: true
  has_many :hoods

  before_validation :set_defaults

  validates :name, :country, presence: true
  validates_uniqueness_of :name, :scope => :province_id

  index [[:name, 1]]

  scope :ordered, order_by(:name, 1)

  def abbr
    province ? province.abbr : country.abbr
  end

  def set_defaults
    self.country ||= province.try(:country)
    self.slug    ||= name.try(:downcase) # don't use slugize
  end

  def self.search(search, page)
    cities = search ? where(:field => /#{search}/i) : all
    cities.page(page)
  end

  def self.drop_down
    ordered.map{|c| [c.name, c.id]}
  end

  def <=> other
    self.name <=> other.name
  end

end
