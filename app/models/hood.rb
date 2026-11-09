# frozen_string_literal: true

# Represents a neighborhood (hood) within a city.
#
# Hoods belong to a city and inherit common geopolitical attributes
# from the `Geopolitocracy` concern (like `name`, `abbr`, `slug`, `pop`, `phone`, `postal`).
# The slug for a hood is typically a combination of the city's slug and the hood's name.
class Hood
  include Mongoid::Document
  include Geopolitocracy # Provides common geopolitical fields like name, abbr, slug, etc.

  # @!attribute [rw] rank
  #   @return [Integer, nil] An optional ranking for the neighborhood, if applicable.
  field :rank, type: Integer

  # @!attribute [rw] city
  #   @return [City] The city this neighborhood belongs to. Required.
  belongs_to :city

  validates :city, presence: true
  validates :name, uniqueness: { scope: :city_id }
  validates :slug, uniqueness: true # slug_1 refuses a twin anyway; this says so before the E11000

  index({ city_id: 1, name: 1 }, { unique: true })
  index({ slug: 1 }, { unique: true }) # The city slug prefixes it, so two names that slugify alike collide

  before_validation :ensure_slug_for_hood

  # Slug is "#{city.slug}-#{name slug}"; prepends the city slug if a bare one was
  # given, and is rebuilt when the hood is renamed or moved to another city.
  def ensure_slug_for_hood
    return if city.blank?

    self.slug = name if persisted? && (name_changed? || city_id_changed?)
    return if slug.blank?

    prefix = "#{city.slug}-"
    self.slug = "#{prefix}#{slug}" unless slug.start_with?(prefix)
  end

  # Retrieves the phone dialing code for the neighborhood.
  # Falls back to the city's phone code if the neighborhood's is not set.
  # Assumes `phone` field is provided by `Geopolitocracy`.
  #
  # @return [String, nil] The phone dialing code.
  def phone
    self[:phone] || city&.phone
  end

  # Retrieves the primary postal code for the neighborhood.
  # Falls back to the city's postal code if the neighborhood's is not set.
  # Assumes `postal` field is provided by `Geopolitocracy`.
  #
  # @return [String, nil] The postal code.
  def postal
    self[:postal] || city&.postal
  end
end
