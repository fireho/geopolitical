class Province
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :name,   type: String
  field :abbr,   type: String

  belongs_to :country

  has_many :cities, :dependent => :destroy

  scope :ordered, order_by(name: 1)

  validates_presence_of :country
  validates_presence_of :name#, :abbr

  validates_uniqueness_of :name, :abbr,  :scope => :country_id

end
