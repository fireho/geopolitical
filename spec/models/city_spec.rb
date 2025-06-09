require 'spec_helper'

# Specs for the City model, covering its attributes, validations,
# associations, slug generation, and helper methods.
describe City, type: :model do
  # Default nation and region for many tests
  let!(:nation_br) { Fabricate(:nation, name: 'Brazil', abbr: 'BR') }
  let!(:region_sp) { Fabricate(:region, name: 'São Paulo State', abbr: 'SP', nation: nation_br) }
  let!(:region_mg) { Fabricate(:region, name: 'Minas Gerais', abbr: 'MG', nation: nation_br) }

  describe 'fabrication' do
    it 'can be created with valid attributes' do
      # Assumes the default fabricator creates a valid city with a nation
      expect { Fabricate(:city) }.not_to raise_error
    end

    it 'is valid with a name and nation' do
      city = Fabricate.build(:city, name: 'Testville', nation: nation_br)
      expect(city).to be_valid
    end
  end

  describe 'attributes and aliases' do
    subject(:city) { Fabricate.build(:city, name: 'Populonia', pop: 100_000, nation: nation_br) }

    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:pop) }
    it { is_expected.to respond_to(:population) } # Alias for pop
    it { is_expected.to respond_to(:area) }
    it { is_expected.to respond_to(:geom) }
    it { is_expected.to respond_to(:rbbr) } # region_abbr internal field
    it { is_expected.to respond_to(:region_abbr) } # custom getter

    it 'stores population correctly' do
      puts city.inspect
      expect(city.population).to eq(100_000)
    end

    it 'stores population correctly' do
      expect(city.pop).to eq(100_000)
    end
  end

  describe 'slug generation' do
    context 'when city has no region' do
      let(:city_no_region) { Fabricate.build(:city, name: 'Patópolis', nation: nation_br, region: nil) }

      it 'generates a slug from the name' do
        city_no_region.valid? # Trigger before_validation callbacks
        expect(city_no_region.slug).to eq('patopolis')
      end

      it 'handles names with dots and special characters' do
        city = Fabricate.build(:city, name: 'Mte. Sto. de Algo', nation: nation_br, region: nil)
        city.valid?
        expect(city.slug).to eq('mte-sto-de-algo')
      end
    end

    context 'when city has a region with an abbreviation' do
      let(:city_with_region) { Fabricate.build(:city, name: 'Patópolis', region: region_sp, nation: nation_br) }

      it 'appends the lowercase region abbreviation to the slug' do
        city_with_region.valid?
        expect(city_with_region.slug).to eq('patopolis-sp')
      end
    end

    context 'when city has a region without an abbreviation but with a name' do
      let(:region_no_abbr) { Fabricate(:region, name: 'Região Sem Sigla', abbr: nil, nation: nation_br) }
      let(:city_region_no_abbr) { Fabricate.build(:city, name: 'Cidadela', region: region_no_abbr, nation: nation_br) }

      it 'appends the lowercase parameterized region name to the slug' do
        city_region_no_abbr.valid?
        expect(city_region_no_abbr.slug).to eq('cidadela-regiao-sem-sigla')
      end
    end

    context 'when slug is explicitly set' do
      it 'uses the explicitly set slug and appends region abbr' do
        # NOTE: Geopolitocracy's slug= will parameterize it first.
        # City's ensure_derived_fields_and_slug will then append.
        city = Fabricate.build(:city, name: 'Original Name', slug: 'custom-slug', region: region_mg, nation: nation_br)
        city.valid?
        expect(city.slug).to eq('custom-slug-mg')
      end
    end

    it 'ensures slug uniqueness is handled by validation (tested separately)' do
      # This specific test was about appending region abbr for uniqueness,
      # which is now standard behavior for slug construction.
      # Actual DB uniqueness is tested by `validates :slug, uniqueness: true` in Geopolitocracy.
      city1 = Fabricate(:city, name: 'Patópolis', region: region_sp, nation: nation_br)
      expect(city1.slug).to eq('patopolis-sp')

      # If another city with same name and region is attempted, model validation should fail.
      # If it's same name but different region, slug will be different.
      city2 = Fabricate.build(:city, name: 'Patópolis', region: region_mg, nation: nation_br)
      city2.valid?
      expect(city2.slug).to eq('patopolis-mg')
    end
  end

  describe '#ensure_derived_fields_and_slug callback' do
    context 'deriving nation' do
      it 'derives nation from region if city nation is not set' do
        city = Fabricate.build(:city, name: 'Orphanville', region: region_sp, nation: nil)
        city.valid? # Trigger callback
        expect(city.nation).to eq(nation_br)
      end

      it 'does not overwrite an existing nation' do
        other_nation = Fabricate(:nation, name: 'Otherland', abbr: 'OT')
        city = Fabricate.build(:city, name: 'Steadfast City', region: region_sp, nation: other_nation)
        city.valid?
        expect(city.nation).to eq(other_nation)
      end
    end

    context 'populating rbbr (region abbreviation cache)' do
      it 'populates rbbr from region.abbr' do
        city = Fabricate.build(:city, name: 'Cacheville', region: region_sp, nation: nation_br)
        city.valid?
        expect(city.rbbr).to eq('SP')
      end

      it 'populates rbbr from region.name if abbr is blank' do
        region_no_abbr_name = Fabricate(:region, name: 'Region Name Only', abbr: nil, nation: nation_br)
        city = Fabricate.build(:city, name: 'Cacheville', region: region_no_abbr_name, nation: nation_br)
        city.valid?
        expect(city.rbbr).to eq('Region Name Only')
      end
    end
  end

  describe '#region_abbr getter' do
    it 'returns and caches region.abbr in rbbr field' do
      city = Fabricate.build(:city, name: 'Test City', region: region_sp, nation: nation_br)
      expect(city.rbbr).to be_nil # Initially
      expect(city.region_abbr).to eq('SP')
      expect(city.rbbr).to eq('SP') # Cached
    end

    it 'returns and caches region.name if abbr is blank' do
      region_only_name = Fabricate(:region, name: 'RegionFullName', abbr: '', nation: nation_br)
      city = Fabricate.build(:city, name: 'Test City', region: region_only_name, nation: nation_br)
      expect(city.rbbr).to be_nil
      expect(city.region_abbr).to eq('RegionFullName')
      expect(city.rbbr).to eq('RegionFullName')
    end

    it 'returns nil if no region' do
      city = Fabricate.build(:city, name: 'No Region City', region: nil, nation: nation_br)
      expect(city.region_abbr).to be_nil
      expect(city.rbbr).to be_nil
    end
  end

  describe 'contact info fallbacks' do
    let(:nation_phone_postal) { Fabricate(:nation, phone: '001', postal: 'N0N0N0', abbr: 'NP') }
    let(:region_phone_postal) do
      Fabricate(:region, phone: '002', postal: 'R0R0R0', nation: nation_phone_postal, abbr: 'RP')
    end
    let(:city_only) do
      Fabricate.build(:city, name: 'CityOnly', region: region_phone_postal, nation: nation_phone_postal)
    end
    let(:city_with_own) do
      Fabricate.build(:city, name: 'CityOwn', phone: '333', postal: 'C0C0C0', region: region_phone_postal,
                             nation: nation_phone_postal)
    end

    context '#phone' do
      it 'returns own phone if present' do
        expect(city_with_own.phone).to eq('333')
      end
      it 'falls back to region phone' do
        city_only.phone = nil # Ensure city's own phone is nil
        expect(city_only.phone).to eq('002')
      end
      it 'falls back to nation phone if region phone is also nil' do
        city_only.phone = nil
        region_phone_postal.phone = nil
        expect(city_only.phone).to eq('001')
      end
    end

    context '#postal' do
      it 'returns own postal if present' do
        expect(city_with_own.postal).to eq('C0C0C0')
      end
      it 'falls back to region postal' do
        city_only.postal = nil
        expect(city_only.postal).to eq('R0R0R0')
      end
      it 'falls back to nation postal if region postal is also nil' do
        city_only.postal = nil
        region_phone_postal.postal = nil
        expect(city_only.postal).to eq('N0N0N0')
      end
    end
  end

  describe 'hood contact info collection' do
    let(:city_with_hoods) { Fabricate(:city, nation: nation_br) }
    let!(:hood1) { Fabricate(:hood, city: city_with_hoods, phone: '111', postal: 'AAA') }
    let!(:hood2) { Fabricate(:hood, city: city_with_hoods, phone: '222', postal: 'BBB') }
    let!(:hood3) { Fabricate(:hood, city: city_with_hoods, phone: '111', postal: nil) } # Duplicate phone, nil postal

    context '#phones' do
      it 'collects unique, non-nil phone numbers from hoods' do
        expect(city_with_hoods.phones).to match_array(%w[111 222])
      end
    end
    context '#postals' do
      it 'collects unique, non-nil postal codes from hoods' do
        expect(city_with_hoods.postals).to match_array(%w[AAA BBB])
      end
    end
  end

  describe 'string representations' do
    let(:city_mg) { Fabricate.build(:city, name: 'Ibirité', region: region_mg, nation: nation_br) }
    let(:city_no_region_abbr) do
      region = Fabricate(:region, name: 'Terra Nova', abbr: nil, nation: nation_br)
      Fabricate.build(:city, name: 'Canto Bom', region: region, nation: nation_br)
    end

    context '#to_s' do
      it 'returns "name/region_abbr" if region_abbr exists' do
        expect(city_mg.to_s).to eq('Ibirité/MG')
      end
      it 'returns "name/region_name" if region_abbr is nil but region_name exists' do
        expect(city_no_region_abbr.to_s).to eq('Canto Bom/Terra Nova')
      end
      it 'returns just name if no region' do
        city = Fabricate.build(:city, name: 'Solitaria', region: nil, nation: nation_br)
        expect(city.to_s).to eq('Solitaria')
      end
    end

    context '#with_region' do
      it 'formats with default separator "/"' do
        expect(city_mg.with_region).to eq('Ibirité/MG')
      end
      it 'formats with custom separator' do
        expect(city_mg.with_region(' - ')).to eq('Ibirité - MG')
      end
    end

    context '#with_nation' do
      it 'formats as "name/region_abbr/nation_abbr"' do
        expect(city_mg.with_nation).to eq('Ibirité/MG/BR')
      end
      it 'formats with custom separator' do
        expect(city_mg.with_nation(' | ')).to eq('Ibirité | MG | BR')
      end
      it 'handles missing region abbreviation correctly' do
        expect(city_no_region_abbr.with_nation).to eq('Canto Bom/Terra Nova/BR')
      end
    end
  end

  describe 'associations' do
    subject(:city) { Fabricate.build(:city) } # Assumes fabricator sets up nation

    it { is_expected.to belong_to(:nation) }
    it { is_expected.to belong_to(:region).with_optional }
    it { is_expected.to have_many(:hoods).with_dependent(:destroy) }
    # it { is_expected.to have_one(:nation_governancy).with_as(:nation_capital).of_type('Nation') }
    # it { is_expected.to have_one(:region_governancy).with_as(:region_capital).of_type('Region') }
  end

  describe 'validations' do
    subject(:city) { Fabricate.build(:city, name: 'Valid City', nation: nation_br) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:nation) }
    # Slug presence and uniqueness are covered by Geopolitocracy concern

    it 'validates uniqueness of name scoped to region_id' do
      Fabricate(:city, name: 'Duplicate Name City', region: region_sp, nation: nation_br)
      new_city = Fabricate.build(:city, name: 'Duplicate Name City', region: region_sp, nation: nation_br)
      expect(new_city).not_to be_valid
      expect(new_city.errors[:name]).to include('must be unique within its region')
    end

    it 'allows same name in different regions' do
      Fabricate(:city, name: 'Common Name City', region: region_sp, nation: nation_br)
      new_city_other_region = Fabricate.build(:city, name: 'Common Name City', region: region_mg, nation: nation_br)
      expect(new_city_other_region).to be_valid
    end

    context '#region_inside_nation_if_region_present' do
      let(:other_nation) { Fabricate(:nation, name: 'ForeignLand', abbr: 'FL') }
      let(:foreign_region) { Fabricate(:region, name: 'Foreign State', abbr: 'FS', nation: other_nation) }

      it 'is valid if region is nil' do
        city = Fabricate.build(:city, name: 'NoRegionCity', region: nil, nation: nation_br)
        expect(city).to be_valid
      end

      it 'is valid if region and city share the same nation' do
        city = Fabricate.build(:city, name: 'LocalCity', region: region_sp, nation: nation_br)
        expect(city).to be_valid
      end

      it 'is invalid if region belongs to a different nation than the city' do
        city = Fabricate.build(:city, name: 'ConfusedCity', region: foreign_region, nation: nation_br)
        expect(city).not_to be_valid
        expect(city.errors[:region]).to include("must be within the same nation as the city. Region's nation: FL, City's nation: BR.")
      end

      it 'is valid if city nation is not yet set (covered by nation presence validation)' do
        # This scenario relies on nation presence validation to catch the missing nation.
        # The region_inside_nation validation itself shouldn't blow up.
        city = Fabricate.build(:city, name: 'AlmostCity', region: region_sp, nation: nil)
        city.valid? # Trigger validations
        # It will be invalid due to missing nation, but not specifically from region_inside_nation erroring out.
        expect(city.errors[:nation]).to include("can't be blank")
        # Check that it doesn't add the region error in this specific case of nil city.nation
        expect(city.errors[:region]).not_to include(/must be within the same nation/)
      end
    end
  end

  describe 'scopes and search' do
    let!(:city_a) { Fabricate(:city, name: 'Abadia', pop: 500, nation: nation_br, region: region_mg) } # Slug: abadia-mg
    # Slug: xangrila-sp
    let!(:city_x) do
      Fabricate(:city, name: 'Xangrilá', pop: 5000, nation: nation_br, region: region_sp)
    end
    context '.ordered (by name)' do
      it 'sorts cities by name ascending' do
        expect(City.ordered.to_a).to eq [city_a, city_x]
      end
    end

    context '.population (by pop descending)' do
      it 'sorts cities by population descending' do
        expect(City.population.to_a).to eq [city_x, city_a]
      end
    end

    context '.search (delegates to Geopolitocracy)' do
      it 'finds a city by its name (converted to slug prefix)' do
        # Search for "Abadia" should match "abadia-mg"
        results = City.search('Abadia')
        expect(results.first).to eq(city_a)
      end

      it 'finds a city by partial name (converted to slug prefix)' do
        results = City.search('Xan')
        expect(results.first).to eq(city_x)
      end

      it 'is case-insensitive' do
        results = City.search('xAnGrIlÁ')
        expect(results.first).to eq(city_x)
      end

      it 'handles special characters in search term' do
        city_sao = Fabricate(:city, name: 'São Paulo', region: region_sp, nation: nation_br) # slug: sao-paulo-sp
        results = City.search('São Paulo')
        expect(results.first).to eq(city_sao)
      end

      it 'returns empty if no match' do
        expect(City.search('NonExistentCity').count).to eq(0)
      end

      it 'can perform an exact slug match' do
        exact_results = City.search('abadia-mg', true)
        expect(exact_results.first).to eq(city_a)
        partial_results = City.search('abadia', true) # This won't match "abadia-mg" exactly
        expect(partial_results.count).to eq(0)
      end
    end
  end

  describe 'geospatial features' do
    # Mongoid::Geospatial needs indexes to be created for geo queries.
    # This is often done via `rake db:mongoid:create_indexes` or `Model.create_indexes`.
    # For tests, ensure indexes are created if not handled by a global setup.
    before(:all) do
      City.create_indexes
    end

    # São Paulo coords
    let(:city_geom) do
      Fabricate(:city, name: 'Central Point', geom: { type: 'Point', coordinates: [-46.6333, -23.5505] },
                       nation: nation_br)
    end
    it 'can store and retrieve geometry' do
      expect(city_geom.geom).to be_present
      expect(city_geom.geom.x).to eq(-46.6333) # Longitude
      expect(city_geom.geom.y).to eq(-23.5505) # Latitude
    end

    context '.nearby' do
      let!(:nearby_city) do
        Fabricate(:city, name: 'NearbyVille', geom: { type: 'Point', coordinates: [-46.6300, -23.5500] },
                         nation: nation_br)
      end
      let!(:far_city)    do
        Fabricate(:city, name: 'FarAwayLand', geom: { type: 'Point', coordinates: [-40.0000, -20.0000] },
                         nation: nation_br)
      end

      it 'finds cities close to a given point' do
        # Using city_geom's coordinates as the center point for the search
        results = City.nearby(city_geom.geom)
        expect(results).to include(city_geom)
        expect(results).to include(nearby_city)
        expect(results).not_to include(far_city)
        # The order depends on distance; city_geom should be first or very close.
        expect(results.first).to eq(city_geom) # or nearby_city if it's closer due to precision
      end
    end
  end

  describe 'equality and comparison' do
    let(:city1_sp) { Fabricate(:city, name: 'City One', region: region_sp, nation: nation_br) } # slug: city-one-sp
    let(:city1_sp_again) { City.find(city1_sp.id) } # Same object, different instance
    let(:city1_mg) { Fabricate(:city, name: 'City One', region: region_mg, nation: nation_br) } # slug: city-one-mg
    let(:city2_sp) { Fabricate(:city, name: 'City Two', region: region_sp, nation: nation_br) } # slug: city-two-sp

    context '#==' do
      it 'returns true for cities with the same slug' do
        # Manually set slug for city1_sp_again to ensure it matches city1_sp after callbacks
        city1_sp_again.valid? # Ensure slug is generated
        expect(city1_sp == city1_sp_again).to be true
      end

      it 'returns false for cities with different slugs' do
        expect(city1_sp == city1_mg).to be false
        expect(city1_sp == city2_sp).to be false
      end

      it 'returns false when comparing with a non-City object' do
        expect(city1_sp == 'not a city').to be false
      end
    end

    context '#<=>' do
      it 'sorts cities based on their slugs' do
        # city-one-mg, city-one-sp, city-two-sp
        # Need to ensure slugs are generated before sort
        [city1_sp, city1_mg, city2_sp].each(&:valid?)
        sorted_cities = [city1_mg, city1_sp, city2_sp].sort
        expect(sorted_cities).to eq([city1_mg, city1_sp, city2_sp])
      end

      it 'returns nil when comparing with a non-City object' do
        expect(city1_sp <=> 'not a city').to be_nil
      end
    end
  end
end
