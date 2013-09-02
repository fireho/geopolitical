class Address
  include Mongoid::Document
  include Mongoid::Symbolize
  include Mongoid::Timestamps
  include Mongoid::Geospatial

  field :zip,     type: String
  field :name,    type: String
  field :title,   type: String
  field :number,  type: String
  field :extra,   type: String
  field :info,    type: String
  field :geom,    type: Point

  field :hood_name,  type: String
  field :city_name,  type: String
  field :region_name,  type: String
  field :country_name,   type: String

  embedded_in :addressable, polymorphic: true

  # belongs_to :country
  # belongs_to :city
  # belongs_to :hood
  validates :name, presence: true

  def print_location
    "#{hood_name} #{city_name} - #{region_name} "
  end

  def print_full_location
    print_location + country_name
  end

  def geom
    g = super
    unless g
      self.geom = '0,0'
      return super
    end
    g
  end

  def geom=(data)
    self[:geom] = data.split(',')
  end

  def form_geom
    "#{geom.try(:x)},#{geom.try(:y)}"
  end

  def form_geom=(data)
    self.geom = data
  end

  def to_s
    "#{name} #{number}" + print_location
  end
  #index tie_id: 1, created_at: -1
  # symbolize :kind, :in => [:street, :avenue, :road], default: :street

end
