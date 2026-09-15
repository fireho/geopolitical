# frozen_string_literal: true

module Geopolitical
  module Postal
    #
    # A Brazilian CEP → street, hood and City, off the Correios data.
    #
    # BrasilAPI v2, not ViaCEP: ViaCEP answers {"erro": "true"} for a
    # town-wide CEP like 37958-000, BrasilAPI answers it with the IBGE code.
    # Its coordinates are the city's centroid, not the street, so they are
    # not read. An answer is a suggestion a person may overwrite — the
    # provider even places 99999-999 somewhere.
    #
    # ponytail: one free provider, no key. A second one the day this one is
    # down long enough to notice.
    #
    module Brasilapi
      URL = 'https://brasilapi.com.br/api/cep/v2/%s'

      module_function

      def find(code, nation: 'BR')
        return unless nation.to_s.upcase == 'BR'

        digits = code.to_s.gsub(/\D/, '')
        return unless digits.size == 8

        body = Postal.cached("geopolitical/postal/#{digits}") { Postal.http(format(URL, digits)) }
        found(body, "#{digits[0, 5]}-#{digits[5, 3]}") if body
      end

      def found(body, postal)
        city = Postal.city(nation: 'BR', state: body['state'], name: body['city'], code: body.dig('ibge', 'city'))
        Found.new(postal: postal, street: body['street'].presence, number: nil,
                  hood: body['neighborhood'].presence, city: city, ref: nil)
      end
    end
  end
end
