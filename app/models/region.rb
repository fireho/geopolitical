#
# Region/Province/Estado
#
class Region
  include Mongoid::Document
  include Geopolitocracy

  field :timezone, type: String

  belongs_to :nation

  has_many :cities,  dependent: :destroy
  belongs_to :capital, class_name: 'City'

  validates :nation, presence: true
  validates :name,   uniqueness: { scope: :nation_id }
  validates :abbr,   uniqueness: { scope: :nation_id, allow_nil: true }

  index abbr: 1
  index nation_id: 1, name: 1

  # National dialing code / or International
  def phone
    self[:phone] || nation.phone
  end

  def postal
    self[:postal] || nation.postal
  end
end
