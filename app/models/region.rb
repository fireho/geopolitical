#
# Region/Province/Estado
#
class Region
  include Mongoid::Document
  include Geopolitocracy

  field :abbr,   type: String
  field :codes,  type: Array # phone codes

  belongs_to :nation

  has_many :cities,  dependent: :destroy

  scope :ordered, -> { order_by(name: 1) }

  validates :nation, presence: true
  validates :name,   presence: true,  uniqueness: { scope: :nation_id }
end
