class Region
  include Mongoid::Document
  include Geopolitical::Helpers

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String,  localize: true
  field :abbr,   type: String
  field :codes,  type: Array # phone codes

  belongs_to :nation

  has_many :cities, :dependent => :destroy

  scope :ordered, order_by(name: 1)

  validates :nation, presence: true
  validates :name,   presence: true

  validates :name,   uniqueness: { :scope => :nation_id }


end
