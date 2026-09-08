# frozen_string_literal: true

#
# Provides common fields, validations, and helper methods for geopolitical entities
# like Nations, Regions, Cities, and Hoods.
#
# NOTE: A Geonames ID is used as ID
#
# It includes fields for names, abbreviations, population, codes, and contact details.
# It also handles automatic slug generation and provides a basic search functionality.
#
module Geopolitocracy
  extend ActiveSupport::Concern

  # Turns any name into a URL-friendly slug: "São Paulo" => "sao-paulo".
  # Latin script is transliterated to ASCII (accents stripped via NFKD, then
  # æ/ø/ß/đ via I18n); other scripts (日本, Москва, دبي) keep their letters so
  # the slug is never blank: "東京" => "東京", "Санкт-Петербург" => "санкт-петербург".
  # @param text [String]
  # @return [String]
  def self.slugify(text)
    # NFC first: decomposed input (macOS filenames, some form posts) would otherwise
    # split a Latin run on its combining marks — "São" => "sa-o".
    latin = text.to_s.unicode_normalize(:nfc).delete('.').gsub(/\p{Latin}+/) do |word|
      ActiveSupport::Inflector.transliterate(word.unicode_normalize(:nfkd).gsub(/\p{Mn}/, ''))
    end
    latin.gsub(/[^\p{Alnum}]+/, '-').gsub(/^-+|-+$/, '').downcase
  end

  included do
    # @!group Fields

    # @!attribute [rw] name
    #   @return [String] The primary name of the entity. Localized.
    #   Automatically titleized on assignment if it doesn't contain mixed-case characters.
    field :name,    type: String, localize: true
    # @!attribute [rw] alt
    #   @return [String, nil] An alternative name or spelling for the entity. Localized.
    field :alt,     type: String, localize: true, default: nil
    # @!attribute [rw] abbr
    #   @return [String, nil] A common abbreviation for the entity (e.g., "NY" for New York).
    field :abbr,    type: String, default: nil
    # @!attribute [rw] nick
    #   @return [String, nil] A nickname or colloquial name for the entity.
    field :nick,    type: String, default: nil

    # @!attribute [rw] souls
    #   @return [Integer, nil] The population count of the entity. Note: `pop` was taken by mongoid
    field :souls, type: Integer, default: nil
    # @!attribute [rw] ascii
    #   @return [String, nil] An ASCII-only representation of the name, useful for systems that don't support Unicode.
    field :ascii,   type: String, default: nil
    # @!attribute [rw] code
    #   @return [String, nil] A code associated with the entity (e.g., FIPS code, ISO 3166-2 subdivision code).
    #   Its uniqueness might be scoped by a parent entity (e.g., nation_id) in the including class.
    field :code,    type: String, default: nil
    # @!attribute [rw] slug
    #   @return [String] A URL-friendly slug, automatically generated from the name if not provided.
    #   Guaranteed to be present and unique across all documents including this concern.
    field :slug,    type: String
    # @!attribute [rw] postal
    #   @return [String, nil] The primary postal code or prefix for the entity.
    field :postal,  type: String, default: nil
    # @!attribute [rw] phone
    #   @return [String, nil] The primary phone dialing code for the entity.
    field :phone,   type: String, default: nil

    # @!group Aliases
    # @!attribute [rw] population # This alias might still be problematic if Mongoid defines a 'population' method.
    #   @see #souls  # For now, keeping it as it was a direct alias to 'pop'.
    alias_method :population, :souls
    alias_method :population=, :souls=

    # @!group Validations
    validates :name, presence: true
    validates :slug, presence: true # Uniqueness will be handled by including models with appropriate scope
    # @!endgroup

    # @!group Indexes
    # NOTE: no plain slug index here — each model declares its own (unique where it
    # can be), and a duplicate key declaration would silently shadow theirs.
    index({ name: 1 }) # For sorting and lookups by name
    index({ abbr: 1 }, { sparse: true }) # Sparse as abbr can be nil
    index({ code: 1 }, { sparse: true }) # Sparse as code can be nil
    # @!endgroup

    before_validation :ensure_slug_is_generated

    # @!group Scopes
    # @!method self.ordered
    #   @return [Mongoid::Criteria] Documents ordered by name ascending.
    scope :ordered, -> { order_by(name: :asc) }
    # @!endgroup

    # Ensures that a slug is generated from the name if the slug is currently blank.
    # This method is called before validation.
    # It uses the custom `slug=` setter which handles parameterization.
    def ensure_slug_is_generated
      return unless slug.blank? && name.present?

      self.slug = name # Will trigger the custom slug setter
    end

    # Custom writer for the name attribute.
    # It titleizes the input string if it doesn't already contain mixed-case characters.
    # @param new_name [String] The new name.
    def name=(new_name)
      if new_name.present? && new_name !~ /[A-Z][a-z]/
        super(new_name.titleize)
      else
        super
      end
    end

    # Custom writer for the slug attribute. See {Geopolitocracy.slugify}.
    # @param new_slug_source [String] The string to be converted into a slug.
    def slug=(new_slug_source)
      super(new_slug_source.present? ? Geopolitocracy.slugify(new_slug_source) : nil)
    end

    # Default string representation of the entity.
    # @return [String] The name of the entity, or its slug if the name is not set.
    def to_s
      name.presence || slug.presence || ''
    end

    # @!group Class Methods
    # Performs a search for entities where the slug starts with the given text (after parameterization).
    #
    # @param query_text [String] The text to search for.
    # @param exact_match [Boolean] If true, searches for an exact match of the parameterized query.
    #                             If false (default), searches for slugs starting with the parameterized query.
    # @return [Mongoid::Criteria] A criteria object for fetching matching documents.
    def self.search(query_text, exact: false)
      return none if query_text.blank? # Return an empty criteria if query is blank

      parameterized_query = Geopolitocracy.slugify(query_text)
      return none if parameterized_query.blank?

      if exact # matches the exact slug
        where(slug: parameterized_query)
      else
        where(slug: /^#{Regexp.escape(parameterized_query)}/)
      end
    end
    # @!endgroup
  end
end
