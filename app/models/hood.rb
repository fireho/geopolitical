#
# Hood/Neighborhood
#
class Hood
  include Mongoid::Document

  field :gid,   type: Integer
  field :slug,  type: String
  field :name,  type: String, localize: true
  field :souls, type: Integer
  field :zip,   type: Integer
  field :rank,  type: Integer

  belongs_to :city

  validates  :city, :name, presence: true

  scope :ordered, -> { order_by(name: 1) }

  def to_s
    name || slug
  end

end
