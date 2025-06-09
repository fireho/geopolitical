# frozen_string_literal: true

#
# Serializes City objects for API responses.
#
# Includes basic city information along with its region and nation context.
class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :formatted_name, :population, :area,
             :nation_id, :region_id, :region_abbr, :nation_abbr,
             :coordinates

  # @!attribute [r] id
  #   @return [String] The unique identifier of the city (BSON::ObjectId as string).
  # @!attribute [r] name
  #   @return [String] The base name of the city.
  # @!attribute [r] slug
  #   @return [String] The URL-friendly slug for the city.
  # @!attribute [r] population
  #   @return [Integer, nil] The population of the city.
  # @!attribute [r] area
  #   @return [Integer, nil] The area of the city in square meters.
  # @!attribute [r] nation_id
  #   @return [String, nil] The ID of the nation this city belongs to.
  # @!attribute [r] region_id
  #   @return [String, nil] The ID of the region this city belongs to.
  # @!attribute [r] region_abbr
  #   @return [String, nil] The abbreviation of the city's region.
  # @!attribute [r] nation_abbr
  #   @return [String, nil] The abbreviation of the city's nation.

  # Returns the city's name, potentially formatted with its region's abbreviation.
  # e.g., "CityName/RegionAbbr"
  # @return [String] The formatted name of the city.
  def formatted_name
    object.with_region
  end

  # Returns the population of the city.
  # @return [Integer, nil]
  def population
    object.pop
  end

  # Returns the ID of the nation this city belongs to, as a string.
  # @return [String, nil]
  def nation_id
    object.nation_id&.to_s
  end

  # Returns the ID of the region this city belongs to, as a string.
  # @return [String, nil]
  def region_id
    object.region_id&.to_s
  end

  # Returns the abbreviation of the city's region.
  # @return [String, nil]
  def region_abbr
    object.region_abbr # Uses the City#region_abbr method which handles loading
  end

  # Returns the abbreviation of the city's nation.
  # @return [String, nil]
  def nation_abbr
    object.nation&.abbr
  end

  # Returns the geographical coordinates of the city.
  # @return [Hash, nil] A hash with `:latitude` and `:longitude` keys, or nil if geom is not set.
  #   Example: `{ latitude: 40.7128, longitude: -74.0060 }`
  def coordinates
    return nil unless object.geom.present?

    # Mongoid::Geospatial::Point stores coordinates as [longitude, latitude]
    { longitude: object.geom.x, latitude: object.geom.y }
  end
end
