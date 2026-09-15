# frozen_string_literal: true

module Geopolitical
  module Postal
    #
    # Geoapify: OpenStreetMap data, 3,000 requests a day free, and a licence
    # that lets you keep what you picked. Address autocomplete while typing,
    # place details on the pick. No sessions — every request is one credit.
    #
    module Geoapify
      AUTOCOMPLETE = 'https://api.geoapify.com/v1/geocode/autocomplete'
      DETAILS = 'https://api.geoapify.com/v2/place-details'

      module_function

      def suggest(text, nation:, **)
        query = { text: text, format: 'json', lang: Postal.language,
                  filter: ("countrycode:#{nation.to_s.downcase}" if nation.present?),
                  apiKey: Geopolitical.postal_key }.compact
        answer = Postal.http("#{AUTOCOMPLETE}?#{URI.encode_www_form(query)}") or return []

        Array(answer['results']).filter_map do |result|
          Suggestion.new(ref: result['place_id'], text: result['formatted']) if result['place_id']
        end
      end

      def pick(ref, **)
        query = URI.encode_www_form(id: ref, lang: Postal.language, apiKey: Geopolitical.postal_key)
        answer = Postal.http("#{DETAILS}?#{query}") or return
        place = answer.dig('features', 0, 'properties') or return

        Found.new(postal: place['postcode'], street: place['street'], number: place['housenumber'],
                  hood: place['suburb'] || place['district'],
                  city: Postal.city(nation: place['country_code'], state: place['state_code'], name: place['city']),
                  ref: place['place_id'] || ref)
      end
    end
  end
end
