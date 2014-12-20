#
# Region/Province/Estado
#
class Region
  include Mongoid::Document
  include Geopolitocracy

  field :zips,   type: Array  # zip codes
  field :codes,  type: Array  # phone codes

  belongs_to :nation

  has_many :cities,  dependent: :destroy

  validates :nation, presence: true
  validates :name,   presence: true,  uniqueness: { scope: :nation_id }
end
