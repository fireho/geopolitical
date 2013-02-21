class Country
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :name,   type: String
  field :abbr,   type: String
  field :code    # optional phone/whatever code

  has_many :provinces, :dependent => :destroy
  has_many :cities,    :dependent => :destroy

  validates :name, :abbr, uniqueness: true, presence: true

end
