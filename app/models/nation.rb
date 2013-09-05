class Nation
  include Mongoid::Document
  include Geopolitical::Helpers

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String, localize: true
  field :abbr,   type: String
  field :code    # optional phone/whatever code
  field :zip,    type: String
  field :cash,   type: String
  field :lang,   type: String

  has_many :regions, :dependent => :destroy
  has_many :cities,    :dependent => :destroy

  scope :ordered, order_by(name: 1)

  validates :slug, :abbr, uniqueness: true, presence: true

  alias :currency :cash


end
