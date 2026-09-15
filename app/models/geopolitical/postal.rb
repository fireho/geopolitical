# frozen_string_literal: true

require 'net/http'
require 'json'
require 'active_support/core_ext/object/blank'

module Geopolitical
  #
  # An address in, a `Found` out — the street, the number, the hood, the
  # postal code and the City (found, or made under its state's Region).
  #
  #   suggest(text, session:)   the list while a person types    free, nothing kept
  #   pick(ref, session:)       the one they chose               one call, yours to store
  #   find(cep)                 a Brazilian CEP                  BrasilAPI, no key
  #
  # `suggest` and `pick` go to `Geopolitical.postal_provider` (:google or
  # :geoapify) with `Geopolitical.postal_key`; with either unset the search is
  # off and answers [] / nil. Every call leaves through `http`, which answers
  # nil for anything but a 200 with JSON — offline, a bad key, a timeout.
  #
  # Only CEPs are cached: Google's terms keep the picked address yours, but
  # not a cache of its answers.
  #
  module Postal
    Found = Data.define(:postal, :street, :number, :hood, :city, :ref)
    Suggestion = Data.define(:ref, :text)

    module_function

    def suggest(text, session: nil, nation: nil)
      text = text.to_s.strip
      api = provider
      return [] if api.nil? || text.size < 3

      api.suggest(text, session:, nation:)
    end

    def pick(ref, session: nil)
      api = provider
      return if api.nil? || ref.blank?

      api.pick(ref.to_s, session:)
    end

    def find(code, nation: 'BR') = Brasilapi.find(code, nation:)

    # A typo in the provider's name raises: a search that is silently off is
    # a form nobody knows is broken.
    def provider
      return if Geopolitical.postal_provider.blank? || Geopolitical.postal_key.blank?

      { google: Google, geoapify: Geoapify }.fetch(Geopolitical.postal_provider.to_sym)
    end

    def http(url, body: nil, headers: {})
      uri = URI(url)
      request = body ? Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json') : Net::HTTP::Get.new(uri)
      headers.each { |name, value| request[name] = value }
      request.body = JSON.generate(body) if body
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 4) do |net|
        net.request(request)
      end
      response.is_a?(Net::HTTPSuccess) ? JSON.parse(response.body) : nil
    rescue StandardError
      nil
    end

    # By code where the provider has one (IBGE), else by name under the
    # state's Region. One the table lacks is made there: a small town is
    # exactly what a city table is most likely to be missing. No Region for
    # the state, no City — the rest of the address still fills.
    def city(nation:, state:, name:, code: nil)
      known = City.where(code: code).first if code.present?
      return known if known

      region = region(nation, state)
      return if region.nil? || name.blank?

      slug = "#{Geopolitocracy.slugify(name)}-#{Geopolitocracy.slugify(region.abbr)}"
      City.where(slug: slug).first || make_city(name, code, region) || City.where(slug: slug).first
    end

    def region(nation, state)
      country = Nation[nation] or return
      Region.where(nation_id: country.id, abbr: state.to_s.upcase).first
    end

    # Two people picking the same new town at once: the second insert loses to
    # the unique slug index, and the caller finds the first one's City.
    def make_city(name, code, region)
      made = City.create(name: name, code: code.presence, region: region, nation: region.nation)
      made if made.persisted?
    rescue Mongo::Error::OperationFailure
      nil
    end

    def language = defined?(I18n) ? I18n.locale.to_s[0, 2] : 'en'

    def cached(key, &)
      return yield unless defined?(Rails) && Rails.respond_to?(:cache) && Rails.cache

      Rails.cache.fetch(key, expires_in: 86_400, skip_nil: true, &)
    end
  end
end
