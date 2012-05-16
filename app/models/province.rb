class Province
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :name,   type: String
  field :abbr,   type: String

  belongs_to :country
  has_many :cities

  validates :name, presence: true

  index [[:name, 1]]

  scope :ordered, order_by(:name, 1)

end
