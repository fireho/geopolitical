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

  # spatial_index :geom

  attr_writer :x, :y, :z
  belongs_to :province
  belongs_to :country

  index name: 1

  scope :ordered, order_by(name: 1)

  before_validation :create_geom
  validates_presence_of :country
  validates_presence_of :name
  validates_presence_of :geom
  #validates_presence_of :province.. nao pode.
  # validates :province, presence: true

  validates_uniqueness_of :name, :scope => :province_id


  # scope :close_to, GeoHelper::CLOSE


  def abbr
    province ? province.abbr : country.abbr
  end

  def to_s
    "#{name}"
  end


end
