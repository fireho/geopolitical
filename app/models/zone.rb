class Zone
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String,  localize: true
  field :abbr,   type: String

  has_many :enclosed, :dependent => :destroy

  scope :ordered, order_by(name: 1)

  validates :name, presence: true

  validates_uniqueness_of :name

end
