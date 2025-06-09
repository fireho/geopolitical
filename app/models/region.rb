# Represents a region, province, or state within a nation.
#
# Regions belong to a nation and can have multiple cities. They can also have
# a designated capital city. Regions inherit common geopolitical attributes
# from the `Geopolitocracy` concern (like `name`, `abbr`, `slug`, `pop`, `phone`, `postal`).
class Region
  include Mongoid::Document
  include Geopolitocracy # Provides common geopolitical fields like name, abbr, slug, etc.

  # @!attribute [rw] timezone
  #   @return [String, nil] The primary IANA timezone identifier for the region (e.g., "America/New_York").
  field :timezone, type: String

  # @!attribute [rw] nation
  #   @return [Nation] The nation this region belongs to. Required.
  belongs_to :nation

  # @!attribute [rw] cities
  #   @return [Mongoid::Relations::Targets::Enumerable<City>] The cities within this region.
  #   Cities are destroyed if the region is destroyed.
  has_many :cities, dependent: :destroy

  # @!attribute [rw] capital
  #   @return [City, nil] The capital city of this region. Optional.
  belongs_to :capital, inverse_of: :region_capital, class_name: 'City', optional: true

  validates :nation, presence: true
  validates :name, uniqueness: { scope: :nation_id, message: 'must be unique within its nation' }
  # `abbr` (from Geopolitocracy) should also be unique within its nation if present.
  validates :abbr,
            uniqueness: { scope: :nation_id, allow_nil: true, message: 'must be unique within its nation if provided' }
  # Slug (from Geopolitocracy) should be unique within its nation. Presence is already validated by Geopolitocracy.
  validates :slug, uniqueness: { scope: :nation_id, message: 'must be unique within its nation' }

  index({ abbr: 1 }, { sparse: true }) # Sparse index as abbr can be nil
  index({ nation_id: 1, name: 1 }, { unique: true }) # Enforce uniqueness of name within nation
  index({ nation_id: 1, abbr: 1 }, { unique: true, sparse: true }) # Enforce uniqueness of abbr within nation

  # Retrieves the phone dialing code for the region.
  # Falls back to the nation's phone code if the region's is not set.
  # Assumes `phone` field is provided by `Geopolitocracy`.
  #
  # @return [String, nil] The phone dialing code.
  def phone
    self[:phone] || nation&.phone
  end

  # Retrieves the primary postal code scheme or prefix for the region.
  # Falls back to the nation's postal code scheme if the region's is not set.
  # Assumes `postal` field is provided by `Geopolitocracy`.
  #
  # @return [String, nil] The postal code scheme or prefix.
  def postal
    self[:postal] || nation&.postal
  end

  # Default string representation of the region.
  #
  # @return [String] The region's name.
  def to_s
    name
  end

  # Compares this region with another object for equality.
  # Regions are considered equal if they belong to the same nation and have the same name.
  #
  # @param other [Object] The object to compare with.
  # @return [Boolean] True if the other object is a Region and has the same nation and name, false otherwise.
  def ==(other)
    other.is_a?(Region) &&
      nation_id == other.nation_id && # More efficient than loading full nation object
      name == other.name
  end

  # Compares this region with another region for sorting purposes.
  # Comparison is based on the nation's name, then the region's name.
  #
  # @param other [Region] The other region to compare with.
  # @return [-1, 0, 1, nil] -1, 0, or 1 if `other` is a Region; nil otherwise.
  def <=>(other)
    return nil unless other.is_a?(Region)

    if nation_id == other.nation_id
      name <=> other.name
    elsif nation && other.nation # Both have nations, compare nation names
      nation.name <=> other.nation.name
    else # Fallback if nations are not loaded or one is nil
      nation_id <=> other.nation_id # Compare by nation_id as a last resort
    end
  end
end
