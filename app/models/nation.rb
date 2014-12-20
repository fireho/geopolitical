#
# Nation/Country/Flag
#
class Nation
  include Mongoid::Document
  include Geopolitocracy

  field :_id, type: String, default: -> { abbr }

  field :zip,    type: String
  field :cash,   type: String
  field :lang,   type: String # Official/main language
  field :langs,  type: Array  # All official languages

  alias_method :currency, :cash

  validates :abbr, uniqueness: true, presence: true

  has_many :regions, dependent: :destroy
  has_many :cities,  dependent: :destroy

  def abbr=(txt)
    self[:abbr] = txt && txt.upcase
  end

  def ==(other)
    return unless other
    abbr == other.abbr
  end

  def <=>(other)
    name <=> other.name
  end
end
