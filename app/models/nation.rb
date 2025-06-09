#
# Nation/Country/Flag
#
class Nation
  include Mongoid::Document
  include Geopolitocracy

  field :_id, type: String, default: -> { abbr }

  field :gid,    type: Integer # geonames id
  field :tld,    type: String # Top level domain
  field :cash,   type: String # Currency prefix
  field :code3,  type: String # Iso 3166_3
  field :lang,   type: String # Official/main language
  field :langs,  type: Array  # All official languages

  alias currency cash
  alias iso_3166_3 code3

  validates :abbr, uniqueness: true, presence: true

  belongs_to :capital, inverse_of: :nation_capital, class_name: 'City',
                       optional: true

  has_many :regions, dependent: :destroy
  has_many :cities,  dependent: :destroy

  index lang: 1

  # Would miss this in a world...
  def planet
    :earth # id: 1
  end

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
