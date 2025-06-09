# frozen_string_literal: true

# Serializes Region objects for API responses.
#
# Includes essential region attributes like name, abbreviation, timezone,
# population, and its associated nation and capital city.
class RegionSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :abbr, :population, :timezone,
             :nation_id, :nation_abbr, :capital_city_id

  # @!attribute [r] id
  #   @return [String] The unique identifier of the region (BSON::ObjectId as string).
  # @!attribute [r] name
  #   @return [String] The name of the region.
  # @!attribute [r] slug
  #   @return [String] The URL-friendly slug for the region.
  # @!attribute [r] abbr
  #   @return [String, nil] The common abbreviation for the region (e.g., "CA" for California).
  # @!attribute [r] population
  #   @return [Integer, nil] The population of the region.
  # @!attribute [r] timezone
  #   @return [String, nil] The primary IANA timezone identifier for the region.
  # @!attribute [r] nation_id
  #   @return [String] The ID of the nation this region belongs to.
  # @!attribute [r] nation_abbr
  #   @return [String, nil] The abbreviation of the nation this region belongs to.
  # @!attribute [r] capital_city_id
  #   @return [String, nil] The ID of the capital city of this region, if set.

  # Returns the population of the region.
  # @return [Integer, nil]
  def population
    object.pop
  end

  # Returns the ID of the nation this region belongs to, as a string.
  # @return [String]
  def nation_id
    object.nation_id.to_s # nation is required, so nation_id should always be present
  end

  # Returns the abbreviation of the nation this region belongs to.
  # @return [String, nil]
  def nation_abbr
    object.nation&.abbr
  end

  # Returns the ID of the capital city of this region, if set.
  # @return [String, nil]
  def capital_city_id
    object.capital_id&.to_s
  end
end
