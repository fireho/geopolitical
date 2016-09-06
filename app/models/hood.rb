#
# Hood/Neighborhood
#
class Hood
  include Mongoid::Document
  include Geopolitocracy

  field :rank,  type: Integer

  belongs_to :city

  validates :city, presence: true
  validates :name, uniqueness: { scope: :city_id }

  def ensure_slug
    return unless city
    self.slug ||= "#{city.slug}-#{name}"
  end

  def phone
    self[:phone] || city.phone
  end

  def postal
    self[:postal] || city.postal
  end

  def as_json(_opts = {})
    {
      id: id.to_s,
      name: name,
      city: city
    }
  end
end
