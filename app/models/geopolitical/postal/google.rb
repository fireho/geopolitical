# frozen_string_literal: true

module Geopolitical
  module Postal
    #
    # Google Places API (New). The typing is Autocomplete, and a session token
    # makes it free when the session ends in a pick; the pick is one Place
    # Details call. The address the person picked is theirs to keep (Places
    # policy, "Autocomplete for end user addresses"); the suggestion list is
    # not, and neither is a cache of it.
    #
    module Google
      AUTOCOMPLETE = 'https://places.googleapis.com/v1/places:autocomplete'
      DETAILS = 'https://places.googleapis.com/v1/places/%s'

      # Place Details Essentials. One field outside that SKU bills every pick
      # as Pro — half the free allowance, three times the price.
      FIELDS = %w[id formattedAddress addressComponents].freeze

      module_function

      def suggest(text, session:, nation:)
        body = { input: text, sessionToken: session, languageCode: Postal.language,
                 includedRegionCodes: ([nation.to_s.downcase] if nation.present?) }.compact
        answer = Postal.http(AUTOCOMPLETE, body: body, headers: key) or return []

        Array(answer['suggestions']).filter_map do |suggestion|
          place = suggestion['placePrediction'] or next
          Suggestion.new(ref: place['placeId'], text: place.dig('text', 'text'))
        end
      end

      def pick(ref, session:)
        query = URI.encode_www_form({ sessionToken: session, languageCode: Postal.language }.compact)
        url = "#{format(DETAILS, URI.encode_www_form_component(ref))}?#{query}"
        place = Postal.http(url, headers: key.merge('X-Goog-FieldMask' => FIELDS.join(','))) or return

        found(Array(place['addressComponents']), place['id'] || ref)
      end

      # ponytail: locality first, the city in most countries; Brazil often
      # sends only administrative_area_level_2. Real answers settle the order.
      def found(parts, ref)
        Found.new(postal: part(parts, 'postal_code'), street: part(parts, 'route'),
                  number: part(parts, 'street_number'), ref: ref,
                  hood: part(parts, 'sublocality_level_1', 'sublocality', 'neighborhood'),
                  city: Postal.city(nation: part(parts, 'country', text: 'shortText'),
                                    state: part(parts, 'administrative_area_level_1', text: 'shortText'),
                                    name: part(parts, 'locality', 'administrative_area_level_2')))
      end

      # The first component carrying any of the types, in the order asked.
      def part(parts, *types, text: 'longText')
        types.each do |type|
          component = parts.find { |candidate| Array(candidate['types']).include?(type) }
          return component[text] if component
        end
        nil
      end

      def key = { 'X-Goog-Api-Key' => Geopolitical.postal_key }
    end
  end
end
