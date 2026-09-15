# frozen_string_literal: true

require 'spec_helper'

# Geoapify: address autocomplete while typing, place details on the pick —
# OpenStreetMap data, and the licence lets you keep what you picked.
describe Geopolitical::Postal::Geoapify do
  let(:postal) { Geopolitical::Postal }
  let!(:brazil) { Fabricate(:nation, name: 'Brazil', abbr: 'BR') }
  let!(:sp) { Fabricate(:region, name: 'São Paulo', abbr: 'SP', nation: brazil) }

  let(:paulista) do
    { 'formatted' => 'Avenida Paulista 1578, Bela Vista, São Paulo - SP, 01310-200, Brazil',
      'place_id' => '51geo', 'street' => 'Avenida Paulista', 'housenumber' => '1578', 'suburb' => 'Bela Vista',
      'city' => 'São Paulo', 'state' => 'São Paulo', 'state_code' => 'SP', 'postcode' => '01310-200',
      'country_code' => 'br' }
  end

  around do |example|
    Geopolitical.postal_provider = :geoapify
    Geopolitical.postal_key = 'akey'
    I18n.with_locale(:pt) { example.run }
  ensure
    Geopolitical.postal_provider = Geopolitical.postal_key = nil
  end

  it 'suggests addresses for the text, inside the nation' do
    allow(postal).to receive(:http).and_return('results' => [paulista, paulista.except('place_id')])

    list = postal.suggest('av paulista 1578', nation: 'BR')

    expect(list).to eq([postal::Suggestion.new(ref: '51geo', text: paulista['formatted'])])
    expect(postal).to have_received(:http).with(
      'https://api.geoapify.com/v1/geocode/autocomplete?text=av+paulista+1578&format=json&lang=pt' \
      '&filter=countrycode%3Abr&apiKey=akey'
    )
  end

  it 'picks the street, the number, the hood, the postal code and the City' do
    city = Fabricate(:city, name: 'São Paulo', region: sp, nation: brazil)
    allow(postal).to receive(:http).and_return('features' => [{ 'properties' => paulista }])

    found = postal.pick('51geo')

    expect(found).to have_attributes(street: 'Avenida Paulista', number: '1578', hood: 'Bela Vista',
                                     postal: '01310-200', city: city, ref: '51geo')
    expect(postal).to have_received(:http).with('https://api.geoapify.com/v2/place-details?id=51geo&lang=pt&apiKey=akey')
  end

  it 'answers nothing when Geoapify does not' do
    allow(postal).to receive(:http).and_return(nil)

    expect(postal.suggest('av paulista')).to eq([])
    expect(postal.pick('51geo')).to be_nil
  end
end
