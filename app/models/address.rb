class Address
  include Mongoid::Document
  # include Mongoid::Symbolize
  include Mongoid::Timestamps
  include Mongoid::Geospatial

  field :zip,     type: String
  field :name,    type: String # My house, my work...
  field :title,   type: String # St, Rd, Av, Area, Park Foo
  field :number,  type: String # least surprise fail
  field :extra,   type: String
  field :info,    type: String

  field :geom,    type: Point

  field :hood_name,      type: String
  field :city_name,      type: String
  field :region_name,    type: String
  field :nation_name,    type: String

  # embedded_in :addressable, polymorphic: true
  belongs_to :addressable, polymorphic: true

  belongs_to :nation
  belongs_to :region
  belongs_to :city
  belongs_to :hood

  validates :title, presence: true

  before_save :set_caches

  def set_caches
    self.city_name ||= city.name if city
    self.nation_name ||= nation.name if nation
  end

  def print_location
    "#{hood_name} #{city_name} - #{region_name} "
  end

  def print_full_location
    print_location + nation_name
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
