class Zone
  include Mongoid::Document

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String,  localize: true
  field :abbr,   type: String
  field :kind,   type: String

  has_many :zone_members, :dependent => :destroy

  scope :ordered, order_by(name: 1)

  validates :name, presence: true, uniqueness: true


  def members
    zone_members.map(&:member)
  end

  def to_s
    name
  end

end
