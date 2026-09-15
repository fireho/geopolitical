# frozen_string_literal: true

require 'spec_helper'

# Places API (New): autocomplete while typing, Place Details on the pick.
# The answers below are the documented shapes, trimmed to what is read.
describe Geopolitical::Postal::Google do
  let(:postal) { Geopolitical::Postal }
  let!(:brazil) { Fabricate(:nation, name: 'Brazil', abbr: 'BR') }
  let!(:sp) { Fabricate(:region, name: 'São Paulo', abbr: 'SP', nation: brazil) }

  # Place Details Essentials, off Google's pricing page. `id` is IDs Only (free).
  let(:essentials) do
    %w[id addressComponents addressDescriptor adrFormatAddress formattedAddress location
       plusCode postalAddress shortFormattedAddress types viewport]
  end

  let(:suggestions) do
    { 'suggestions' => [
      { 'placePrediction' => {
        'placeId' => 'ChIJpaulista',
        'text' => { 'text' => 'Avenida Paulista, 1578 - Bela Vista, São Paulo - SP, Brasil' }
      } },
      { 'queryPrediction' => { 'text' => { 'text' => 'avenida paulista' } } }
    ] }
  end

  let(:place) do
    { 'id' => 'ChIJpaulista',
      'formattedAddress' => 'Av. Paulista, 1578 - Bela Vista, São Paulo - SP, 01310-200, Brasil',
      'addressComponents' => [
        { 'longText' => '1578', 'shortText' => '1578', 'types' => ['street_number'] },
        { 'longText' => 'Avenida Paulista', 'shortText' => 'Av. Paulista', 'types' => ['route'] },
        { 'longText' => 'Bela Vista', 'shortText' => 'Bela Vista',
          'types' => %w[sublocality_level_1 sublocality political] },
        { 'longText' => 'São Paulo', 'shortText' => 'São Paulo', 'types' => %w[administrative_area_level_2 political] },
        { 'longText' => 'São Paulo', 'shortText' => 'SP', 'types' => %w[administrative_area_level_1 political] },
        { 'longText' => 'Brasil', 'shortText' => 'BR', 'types' => %w[country political] },
        { 'longText' => '01310-200', 'shortText' => '01310-200', 'types' => ['postal_code'] }
      ] }
  end

  around do |example|
    Geopolitical.postal_provider = :google
    Geopolitical.postal_key = 'gkey'
    I18n.with_locale(:pt) { example.run }
  ensure
    Geopolitical.postal_provider = Geopolitical.postal_key = nil
  end

  it 'suggests places for the text, in one billing session, inside the nation' do
    allow(postal).to receive(:http).and_return(suggestions)

    list = postal.suggest('av paulista 1578', session: 'tok', nation: 'BR')

    expect(list).to eq([postal::Suggestion.new(ref: 'ChIJpaulista',
                                               text: 'Avenida Paulista, 1578 - Bela Vista, São Paulo - SP, Brasil')])
    expect(postal).to have_received(:http).with(
      'https://places.googleapis.com/v1/places:autocomplete',
      body: { input: 'av paulista 1578', sessionToken: 'tok', languageCode: 'pt', includedRegionCodes: ['br'] },
      headers: { 'X-Goog-Api-Key' => 'gkey' }
    )
  end

  it 'picks the street, the number, the hood, the postal code and the City' do
    city = Fabricate(:city, name: 'São Paulo', region: sp, nation: brazil)
    allow(postal).to receive(:http).and_return(place)

    found = postal.pick('ChIJpaulista', session: 'tok')

    expect(found).to have_attributes(street: 'Avenida Paulista', number: '1578', hood: 'Bela Vista',
                                     postal: '01310-200', city: city, ref: 'ChIJpaulista')
    expect(postal).to have_received(:http)
      .with('https://places.googleapis.com/v1/places/ChIJpaulista?sessionToken=tok&languageCode=pt',
            headers: { 'X-Goog-Api-Key' => 'gkey', 'X-Goog-FieldMask' => 'id,formattedAddress,addressComponents' })
  end

  # One field outside Essentials and every pick bills as Pro — half the free
  # allowance at three times the price. This is the fence.
  it 'asks for Essentials fields and nothing else' do
    expect(described_class::FIELDS - essentials).to be_empty
  end

  it 'makes the City the table lacks, under the state Google names' do
    allow(postal).to receive(:http).and_return(place)

    city = postal.pick('ChIJpaulista', session: 'tok').city

    expect(city).to be_persisted
    expect(city).to have_attributes(name: 'São Paulo', region: sp, nation: brazil)
  end

  it 'answers nothing when Google does not' do
    allow(postal).to receive(:http).and_return(nil)

    expect(postal.suggest('av paulista', session: 'tok')).to eq([])
    expect(postal.pick('ChIJpaulista', session: 'tok')).to be_nil
  end
end
