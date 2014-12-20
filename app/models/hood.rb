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

  validates :city, presence: true
  validates :name, uniqueness: { scope: :city_id }
end
