# frozen_string_literal: true

#
# Serializes Nation objects for API responses.
#
# Includes essential nation attributes like name, abbreviation, ISO codes,
# currency, and language information.
class NationSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :abbr, :population, :tld,
             :currency, :primary_language, :official_languages,
             :capital_city_id

  # @!attribute [r] id
  #   @return [String] The unique identifier of the nation (usually its abbreviation).
  # @!attribute [r] name
  #   @return [String] The name of the nation.
  # @!attribute [r] slug
  #   @return [String] The URL-friendly slug for the nation.
  # @!attribute [r] abbr
  #   @return [String] The common abbreviation for the nation (e.g., "USA", "DE").
  # @!attribute [r] population
  #   @return [Integer, nil] The population of the nation.
  # @!attribute [r] tld
  #   @return [String, nil] The top-level domain for the nation (e.g., ".us").
  # @!attribute [r] currency
  #   @return [String, nil] The currency symbol or code for the nation (e.g., "$", "EUR").
  # @!attribute [r] primary_language
  #   @return [String, nil] The primary official language code of the nation.
  # @!attribute [r] official_languages
  #   @return [Array<String>] A list of all official language codes for the nation.
  # @!attribute [r] capital_city_id
  #   @return [String, nil] The ID of the capital city of this nation, if set.

  # Returns the population of the nation.
  # @return [Integer, nil]
  def population
    object.pop
  end

  # Returns the primary official language code of the nation.
  # @return [String, nil]
  def primary_language
    object.lang
  end

  # Returns a list of all official language codes for the nation.
  # @return [Array<String>]
  def official_languages
    object.langs || []
  end

  # Returns the ID of the capital city of this nation, if set.
  # @return [String, nil]
  def capital_city_id
    object.capital_id&.to_s
  end
end
