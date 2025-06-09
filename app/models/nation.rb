# frozen_string_literal: true

#
# Represents a nation or country.
#
# Each nation has a unique abbreviation (`abbr`) which also serves as its `_id`.
# It includes geopolitical information such as its Geonames ID, top-level domain,
# currency, ISO 3166-3 code, and languages.
#
# Nations can have a capital city, multiple regions, and multiple cities.
class Nation
  include Mongoid::Document
  include Geopolitocracy

  # The unique identifier for the nation, defaults to its abbreviation.
  # The `abbr` is expected to be provided by the Geopolitocracy concern or set explicitly.
  field :_id, type: String, default: -> { abbr }, overwrite: true

  # @!attribute [rw] gid
  #   @return [Integer] The Geonames identifier for the nation.
  field :gid,    type: Integer
  # @!attribute [rw] tld
  #   @return [String] The top-level domain (e.g., ".us", ".de").
  field :tld,    type: String
  # @!attribute [rw] cash
  #   @return [String] The currency symbol or code (e.g., "$", "EUR").
  field :cash,   type: String
  # @!attribute [rw] code3
  #   @return [String] The ISO 3166-1 alpha-3 code for the country.
  field :code3,  type: String
  # @!attribute [rw] langs
  #   @return [Array<String>] A list of all official language codes.
  field :langs,  type: Array, default: []

  # Alias for the `cash` field.
  # @return [String] The currency symbol or code.
  alias currency cash
  # Alias for the `cash=` writer.
  alias currency= cash=

  # Alias for the `code3` field, representing the ISO 3166-1 alpha-3 code.
  # @return [String] The ISO 3166-1 alpha-3 code.
  # alias iso_3166_3 code3
  # # Alias for the `code3=` writer.
  # alias iso_3166_3= code3=

  validates :abbr, presence: true # Name presence is validated in Geopolitocracy
  validates_uniqueness_of :abbr, case_sensitive: false

  # @!attribute [rw] capital
  #   @return [City] The capital city of this nation.
  belongs_to :capital, inverse_of: :nation_capital, class_name: 'City', optional: true

  # @!attribute [rw] regions
  #   @return [Mongoid::Relations::Targets::Enumerable<Region>] The regions within this nation.
  has_many :regions, dependent: :destroy
  # @!attribute [rw] cities
  #   @return [Mongoid::Relations::Targets::Enumerable<City>] The cities within this nation.
  has_many :cities,  dependent: :destroy

  index({ name: 1 }) # Index for sorting by name, common operation

  # A whimsical method indicating the planet.
  # In a more complex system, this might point to a Planet model.
  # @return [Symbol] Always returns `:earth`.
  def planet
    :earth # In a larger cosmological model, this could be `Planet.find_by(name: 'Earth')`
  end

  # Helper method to retrieve the primary language of the nation.
  # This returns the first language in the `langs` array, if available.
  #
  # @return [String, nil] The primary language code or nil if no languages are set.
  def lang
    langs&.first
  end

  # Sets the abbreviation for the nation.
  # The abbreviation is automatically converted to uppercase.
  #
  # @param new_abbr [String] The new abbreviation.
  # @return [String, nil] The uppercased abbreviation or nil if input was nil.
  def abbr=(new_abbr)
    super(new_abbr&.upcase)
  end

  # Compares this nation with another object for equality.
  # Nations are considered equal if their abbreviations are the same.
  #
  # @param other [Object] The object to compare with.
  # @return [Boolean] True if the other object is a Nation and has the same abbreviation, false otherwise.
  def ==(other)
    other.is_a?(Nation) && abbr == other.abbr
  end

  # Compares this nation with another nation for sorting purposes.
  # Comparison is based on the nation's name.
  #
  # @param other [Nation] The other nation to compare with.
  # @return [-1, 0, 1] -1 if self.name < other.name, 0 if equal, 1 if self.name > other.name.
  # @raise [ArgumentError] if other is not a Nation.
  def <=>(other)
    return nil unless other.is_a?(Nation) # Or raise ArgumentError?

    name <=> other.name
  end
end
