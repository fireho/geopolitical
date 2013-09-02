class City
  include Mongoid::Document
  include Mongoid::Geospatial
  # include GeoHelper

  field :slug   type: String
  field :name   type: String, localize: true
  field :area   type: Integer
  field :gid,   type: Integer
  field :zip,   type: Integer
  field :souls, type: Integer
  field :geom,  type: Point,   spatial: true

  spatial_scope :geom

  attr_writer :x, :y, :z

  belongs_to :region
  belongs_to :country
  has_many :hoods

  index name: 1

  scope :ordered, order_by(name: 1)

  validates_presence_of :country
  validates :slug, presence: true, uniqueness: true
  # validates_presence_of :geom

  validates :name, uniqueness: {  :scope => :region_id  }

  # scope :close_to, GeoHelper::CLOSE


  def abbr
    region ? region.abbr : country.abbr
  end

  def to_s
    "#{name}"
  end


end
