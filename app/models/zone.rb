#
# User created zones
class Zone
  include Mongoid::Document
  include GeoHelper

  field :gid,    type: Integer  # geonames id
  field :slug,   type: String
  field :name,   type: String
  field :abbr,   type: String
  field :i18n,   type: String,  localize: true
  field :kind,   type: String
  field :info,   type: String,  localize: true

  field :active, type: Mongoid::Boolean

  has_many :members, class_name: "Zone::Member", dependent: :destroy

  scope :ordered,  -> { order_by(name: 1) }
  scope :active,   -> { where(active: true) }

  # validates :name, presence: true# , uniqueness: true

  def to_s
    name
  end

  def self.icon
    "globe"
  end

  # Zone::Member
  class Member
    include Mongoid::Document

    belongs_to :zone
    belongs_to :member, polymorphic: true
  end

end
