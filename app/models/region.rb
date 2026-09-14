# frozen_string_literal: true

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
  belongs_to :capital, inverse_of: :region_governancy, class_name: 'City', optional: true

  validates :nation, presence: true
  validates :name, uniqueness: { scope: :nation_id, message: 'must be unique within its nation' }
  # `abbr` (from Geopolitocracy) should also be unique within its nation if present.
  validates :abbr,
            uniqueness: { scope: :nation_id, allow_blank: true, message: 'must be unique within its nation if provided' }
  # Slug (from Geopolitocracy) should be unique within its nation. Presence is already validated by Geopolitocracy.
  validates :slug, uniqueness: { scope: :nation_id, message: 'must be unique within its nation' }

  index({ slug: 1 }) # For .search; global uniqueness is not required, see the compound index below
  index({ abbr: 1 }, { sparse: true }) # Sparse index as abbr can be nil
  index({ nation_id: 1, name: 1 }, { unique: true }) # Enforce uniqueness of name within nation
  # Partial, not sparse: nation_id is always set, so a sparse compound index
  # still indexes every abbr-less region and the second one collides.
  index({ nation_id: 1, abbr: 1 }, { unique: true, partial_filter_expression: { abbr: { '$gt' => '' } } })
  index({ nation_id: 1, slug: 1 }, { unique: true }) # Enforce uniqueness of slug within nation

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
end
