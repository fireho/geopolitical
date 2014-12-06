#
# Nation/Country/Flag
#
class Nation
  include Mongoid::Document
  include Geopolitocracy

  field :_id, type: String, default: -> { abbr }

  field :code    # optional phone/whatever code
  field :zip,    type: String
  field :cash,   type: String
  field :lang,   type: String

  has_many :regions, dependent: :destroy
  has_many :cities,  dependent: :destroy

  scope :ordered, -> { order_by(name: 1) }

  validates :slug, :abbr, uniqueness: true, presence: true

  alias_method :currency, :cash
end
