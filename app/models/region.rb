#
# Region/Province/Estado
#
class Region
  include Mongoid::Document
  include Geopolitocracy

  field :timezone, type: String

  belongs_to :nation

  has_many :cities,  dependent: :destroy

  validates :nation, presence: true
  validates :name,   uniqueness: { scope: :nation_id }
  validates :abbr,   uniqueness: { scope: :nation_id }

  def phone
    self[:phone] || nation.phone
  end

  def postal
    self[:postal] || nation.postal
  end
end
