class Country
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :name,   type: String
  field :abbr,   type: String
  field :code    # optional phone/whatever code

  has_many :cities
  has_many :provinces

  validates :abbr, :name, presence: true

  index [[:name, 1]]

  scope :ordered, order_by(:name, 1)

end


