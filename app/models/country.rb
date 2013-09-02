class Country
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String, localize: true
  field :abbr,   type: String
  field :code    # optional phone/whatever code

  has_many :regions, :dependent => :destroy
  has_many :cities,    :dependent => :destroy

  validates :name, :abbr, uniqueness: true, presence: true

end
