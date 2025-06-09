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
  validates :name, uniqueness: { scope: :city_id, message: 'must be unique within its city' }
  # `abbr` (from Geopolitocracy) could also be validated for uniqueness within the city if used.
  # validates :abbr,
  #           uniqueness: { scope: :city_id, allow_nil: true, message: "must be unique within its city if provided" }

  index({ city_id: 1, name: 1 }, { unique: true })
  # index({ city_id: 1, abbr: 1 }, { unique: true, sparse: true }) # If abbr is used and needs to be unique
  index({ slug: 1 }, { unique: true }) # Hood slugs are globally unique due to city_slug prefix

  before_validation :ensure_slug_for_hood

  # Ensures the slug is generated correctly for the hood.
  # This method is typically called via a `before_validation` callback
  # from the `Geopolitocracy` concern.
  # It customizes the slug to be `city.slug-hood.name` if the city is present
  # and the slug hasn't been set by `Geopolitocracy`'s default (which is usually just `name.parameterize`).
  #
  # Note: `Geopolitocracy`'s `ensure_slug` will likely run first, setting a base slug.
  # This method then refines it. If `Geopolitocracy` sets `slug ||= name.parameterize`,
  # this method will effectively overwrite it if `city` is present.
  # Consider the order of operations or make `Geopolitocracy`'s slug generation more flexible
  # if this causes issues. For now, this assumes `slug` might be nil or a simple name parameterization.
  def ensure_slug_for_hood
    # Geopolitocracy's `ensure_slug_is_generated` callback will have already run,
    # potentially setting a slug based on the hood's name.
    # This method refines it by prepending the city's slug.

    return unless city.present?

    parameterized_name = (name || '').parameterize
    # If Geopolitocracy set a slug, and it's just the parameterized name,
    # or if the slug is still blank, then we build our composite slug.
    if slug == parameterized_name || slug.blank?
      self.slug = "#{city.slug}-#{parameterized_name}" if parameterized_name.present?
    elsif !slug.start_with?("#{city.slug}-")
      # If a slug exists but doesn't seem to be our composite one, prepend city slug.
      # This case might be rare if Geopolitocracy's slug is simple.
      self.slug = "#{city.slug}-#{slug}"
    end

    # If slug is still blank after all this (e.g. name was blank), Geopolitocracy's validation might catch it.
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

  # Provides a JSON representation of the hood.
  #
  # @param _opts [Hash] Options (not currently used).
  # @return [Hash] A hash containing the id, name, and associated city.
  #   The city is typically represented by its default `as_json` or `to_s` representation.
  def as_json(_opts = {})
    {
      id: _id.to_s, # Use _id for Mongoid documents
      name: name,
      # Consider what representation of city is most useful here.
      # city.as_json might be too verbose. city_id or city.slug might be better.
      city_id: city_id.to_s,
      city_slug: city&.slug
      # Or: city: city&.name # if just the name is needed
    }
  end

  # Default string representation of the hood.
  #
  # @return [String] The hood's name.
  def to_s
    name
  end

  # Compares this hood with another object for equality.
  # Hoods are considered equal if they belong to the same city and have the same name.
  #
  # @param other [Object] The object to compare with.
  # @return [Boolean] True if the other object is a Hood and has the same city and name, false otherwise.
  def ==(other)
    other.is_a?(Hood) &&
      city_id == other.city_id &&
      name == other.name
  end

  # Compares this hood with another hood for sorting purposes.
  # Comparison is based on the city's name (or slug), then the hood's name.
  #
  # @param other [Hood] The other hood to compare with.
  # @return [-1, 0, 1, nil] -1, 0, or 1 if `other` is a Hood; nil otherwise.
  # rubocop:disable Metrics/AbcSize
  def <=>(other)
    return nil unless other.is_a?(Hood)

    # Compare by city first, then by hood name
    city_comparison = if city_id == other.city_id
                        0
                      elsif city && other.city
                        (city.slug || city.name) <=> (other.city.slug || other.city.name)
                      else
                        city_id <=> other.city_id # Fallback
                      end

    return city_comparison unless city_comparison&.zero? # If cities are different, result is based on them

    name <=> other.name # If cities are the same (or comparison is 0), compare by hood name
  end
  # rubocop:enable Metrics/AbcSize
end
