# frozen_string_literal: true

require 'spec_helper'

# A trip around the world: scripts, accents, homonyms, city-states.
describe 'World tour', type: :model do
  describe 'slugs' do
    {
      'São Paulo' => 'sao-paulo',           # BR
      'Córdoba' => 'cordoba',               # AR
      'München' => 'munchen',               # DE
      'Baden-Württemberg' => 'baden-wurttemberg',
      "Côte-d'Or" => 'cote-d-or',           # FR
      'Dún Laoghaire' => 'dun-laoghaire',   # IE
      'Kraków' => 'krakow',                 # PL
      'Ærø' => 'aero',                      # DK
      'İstanbul' => 'istanbul',             # TR
      'Hà Nội' => 'ha-noi',                 # VN
      'St. Louis' => 'st-louis',            # US
      '東京' => '東京',                       # JP – no transliteration, keep script
      '서울' => '서울',                       # KR
      'Москва' => 'москва',                 # RU – downcased
      'Санкт-Петербург' => 'санкт-петербург',
      'Αθήνα' => 'αθήνα',                   # GR
      'دبي' => 'دبي',                       # AE
      'मुंबई' => 'मुंबई',                   # IN
      '  New   York  ' => 'new-york'
    }.each do |name, slug|
      it "#{name.strip} => #{slug}" do
        expect(Geopolitocracy.slugify(name)).to eq(slug)
      end
    end
  end

  describe 'nations in every script are valid' do
    %w[日本:JP Россия:RU Ελλάδα:GR مصر:EG भारत:IN 대한민국:KR].each do |pair|
      name, abbr = pair.split(':')
      it name do
        expect(Nation.create(name: name, abbr: abbr)).to be_valid
      end
    end
  end

  describe 'Nation[]' do
    before { Fabricate(:nation, name: 'Brasil', abbr: 'BR') }

    it 'finds by abbr, any case' do
      expect(Nation['br'].name).to eq('Brasil')
      expect(Nation[:BR]).to eq(Nation.find('BR'))
    end
  end

  describe 'Japan 🇯🇵' do
    let(:jp) { Nation.create!(name: '日本', abbr: 'JP', phone: '81', langs: ['ja']) }
    let(:tokyo_to) { Region.create!(name: '東京都', nation: jp, code: '13') }
    let(:tokyo) { City.create!(name_translations: { 'en' => 'Tokyo', 'ja' => '東京' }, region: tokyo_to, nation: jp) }

    it 'slugs a city with a region that has no abbr' do
      expect(tokyo.slug).to eq('tokyo-東京都')
      expect(tokyo.to_s).to eq('Tokyo/東京都')
    end

    it 'hoods inherit the city slug and phone' do
      shibuya = Hood.create!(name: '渋谷', city: tokyo)
      expect(shibuya.slug).to eq('tokyo-東京都-渋谷')
      expect(shibuya.phone).to eq('81')
    end

    it 'searches in either script' do
      tokyo
      expect(City.search('tok').first).to eq(tokyo)
      expect(Region.search('東京').first).to eq(tokyo_to)
    end
  end

  describe 'United States 🇺🇸' do
    let(:us) { Nation.create!(name: 'United States', abbr: 'US', phone: '1') }
    let(:il) { Region.create!(name: 'Illinois', abbr: 'IL', nation: us) }
    let(:ma) { Region.create!(name: 'Massachusetts', abbr: 'MA', nation: us) }

    it 'tells the Springfields apart' do
      a = City.create!(name: 'Springfield', region: il, nation: us)
      b = City.create!(name: 'Springfield', region: ma, nation: us)
      expect([a.slug, b.slug]).to eq(%w[springfield-il springfield-ma])
      expect(City.search('springfield').count).to eq(2)
      expect(City.search('springfield-ma', exact: true).first).to eq(b)
    end

    it 'titleizes shouty or lowercase names only' do
      expect(City.create!(name: 'new york', nation: us).name).to eq('New York')
      expect(City.create!(name: 'LOS ANGELES', nation: us).name).to eq('Los Angeles')
      expect(City.create!(name: 'McAllen', nation: us).name).to eq('McAllen')
    end
  end

  describe 'Singapore 🇸🇬 (city-state)' do
    it 'is its own capital, no region needed' do
      sg = Nation.create!(name: 'Singapore', abbr: 'SG')
      city = City.create!(name: 'Singapore', nation: sg)
      sg.update!(capital: city)
      expect(city.slug).to eq('singapore-sg')
      expect(sg.reload.capital).to eq(city)
      expect(city.nation_governancy).to eq(sg)
      expect(city.with_nation).to eq('Singapore/SG')
    end
  end

  describe 'Germany 🇩🇪' do
    let(:de) { Nation.create!(name: 'Deutschland', abbr: 'DE', postal: '00000', langs: %w[de]) }
    let(:by) { Region.create!(name: 'Bayern', abbr: 'BY', nation: de, timezone: 'Europe/Berlin') }

    it 'walks the whole chain' do
      muc = City.create!(name: 'München', region: by, nation: de, souls: 1_500_000, geom: [11.57, 48.14])
      hood = Hood.create!(name: 'Schwabing', city: muc)
      expect(hood.city.region.nation.planet).to eq(:earth)
      expect(hood.postal).to eq('00000')
      expect(muc.with_nation('-')).to eq('München-BY-DE')
      expect(muc.population).to eq(1_500_000)
      City.create_indexes
      expect(City.nearby(muc.geom).first).to eq(muc)
    end

    it 'refuses a city whose region is in another nation' do
      at = Nation.create!(name: 'Österreich', abbr: 'AT')
      expect(City.new(name: 'Salzburg', region: by, nation: at)).not_to be_valid
    end
  end
  # Regressions found in review, 2026-09.
  describe 'regressions' do
    let(:br) { Nation.create!(name: 'Brasil', abbr: 'BR') }
    let(:sp) { Region.create!(name: 'São Paulo', abbr: 'SP', nation: br) }
    let(:rj) { Region.create!(name: 'Rio de Janeiro', abbr: 'RJ', nation: br) }

    it 'keeps region-less cities in different nations apart' do
      sc = Nation.create!(name: 'Seychelles', abbr: 'SC')
      hk = Nation.create!(name: 'Hong Kong', abbr: 'HK')
      a = City.create!(name: 'Victoria', nation: sc)
      b = City.create!(name: 'Victoria', nation: hk)
      expect([a.slug, b.slug]).to eq(%w[victoria-sc victoria-hk])
    end

    it 'creates the unique slug index it declares' do
      City.create_indexes
      slug_index = City.collection.indexes.find { |i| i['key'] == { 'slug' => 1 } }
      expect(slug_index['unique']).to be(true)
    end

    it 'slugs decomposed (NFD) input like composed input' do
      expect(Geopolitocracy.slugify('São Paulo'.unicode_normalize(:nfd)))
        .to eq(Geopolitocracy.slugify('São Paulo'))
    end

    it 'refreshes abbr and slug when a city moves to another region' do
      city = City.create!(name: 'Santos', region: sp, nation: br)
      expect(city.slug).to eq('santos-sp')
      city.update!(region: rj)
      expect([city.region_abbr, city.slug, city.to_s]).to eq(['RJ', 'santos-rj', 'Santos/RJ'])
    end

    it 'rebuilds a hood slug when it is renamed or moved' do
      santos = City.create!(name: 'Santos', region: sp, nation: br)
      rio = City.create!(name: 'Rio', region: rj, nation: br)
      hood = Hood.create!(name: 'Gonzaga', city: santos)
      expect(hood.slug).to eq('santos-sp-gonzaga')
      hood.update!(name: 'Boqueirão')
      expect(hood.slug).to eq('santos-sp-boqueirao')
      hood.update!(city: rio)
      expect(hood.slug).to eq('rio-rj-boqueirao')
    end

    it 'keeps the other languages when the primary one is set' do
      ca = Nation.create!(name: 'Canada', abbr: 'CA', langs: %w[en fr])
      ca.update!(lang: 'en')
      expect(ca.reload.langs).to eq(%w[en fr])
    end

    it 'returns nil for an unknown abbr' do
      expect(Nation['zz']).to be_nil
    end
  end
end
