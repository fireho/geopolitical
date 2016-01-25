# Serializer for Cities
class CitySerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    object.with_region
  end
end
