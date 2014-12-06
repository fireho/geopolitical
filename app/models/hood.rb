#
# Hood/Neighborhood
#
class Hood
  include Mongoid::Document
  include Geopolitocracy

  field :souls, type: Integer
  field :rank,  type: Integer
  field :zip,   type: Integer

  belongs_to :city

  validates :city, :name, presence: true

  scope :ordered, -> { order_by(name: 1) }

  def to_s
    name || slug
  end
end
