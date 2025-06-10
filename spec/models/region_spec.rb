# frozen_string_literal: true

require 'spec_helper'

# Specs for the Region model, covering its attributes, validations,
# associations, slug generation, and helper methods.
describe Region, type: :model do
  let!(:nation) { Fabricate(:nation, name: 'Testlandia', abbr: 'TL', phone: '001', postal: 'N0N0N0') }

  describe 'fabrication' do
    it 'can be created with valid attributes' do
      # Assumes the default fabricator creates a valid region with a nation
      expect { Fabricate(:region, nation: nation) }.not_to raise_error
    end

    it 'is valid with a name and nation' do
      region = Fabricate.build(:region, name: 'Province One', nation: nation)
      expect(region).to be_valid
    end
  end

  describe 'attributes and defaults' do
    subject(:region) { Fabricate.build(:region, name: 'State of Mind', nation: nation) }

    it { is_expected.to respond_to(:name) } # From Geopolitocracy
    it { is_expected.to respond_to(:abbr) } # From Geopolitocracy
    it { is_expected.to respond_to(:slug) } # From Geopolitocracy
    it { is_expected.to respond_to(:pop) }  # From Geopolitocracy
    it { is_expected.to respond_to(:phone) } # Own method, also field from Geopolitocracy
    it { is_expected.to respond_to(:postal) } # Own method, also field from Geopolitocracy
    it { is_expected.to respond_to(:timezone) }
  end

  describe 'slug generation (from Geopolitocracy)' do
    it 'creates a slug from the name' do
      region = Fabricate.build(:region, name: 'Amapá State', nation: nation)
      region.valid? # Trigger callbacks
      expect(region.slug).to eq('amapa-state')
    end

    it 'handles names with special characters for slug' do
      region = Fabricate.build(:region, name: 'New Brunswick/Nouveau-Brunswick', nation: nation)
      region.valid?
      expect(region.slug).to eq('new-brunswick-nouveau-brunswick')
    end
  end

  describe 'contact info fallbacks' do
    let(:region_only) { Fabricate.build(:region, name: 'RegionOnly', nation: nation) }
    let(:region_with_own) do
      Fabricate.build(:region, name: 'RegionOwn', phone: '099', postal: 'R9R9R9', nation: nation)
    end

    context '#phone' do
      it 'returns own phone if present' do
        expect(region_with_own.phone).to eq('099')
      end
      it 'falls back to nation phone' do
        region_only.phone = nil # Ensure region's own phone is nil
        expect(region_only.phone).to eq('001')
      end
      it 'returns nil if own and nation phone are nil' do
        nation.phone = nil
        region_only.phone = nil
        expect(region_only.phone).to be_nil
      end
    end

    context '#postal' do
      it 'returns own postal if present' do
        expect(region_with_own.postal).to eq('R9R9R9')
      end
      it 'falls back to nation postal' do
        region_only.postal = nil
        expect(region_only.postal).to eq('N0N0N0')
      end
      it 'returns nil if own and nation postal are nil' do
        nation.postal = nil
        region_only.postal = nil
        expect(region_only.postal).to be_nil
      end
    end
  end

  describe 'associations' do
    subject { Fabricate.build(:region, nation: nation) }

    it { is_expected.to belong_to(:nation) }
    it { is_expected.to have_many(:cities).with_dependent(:destroy) }
    it { is_expected.to belong_to(:capital).of_type(City).with_optional }
  end

  describe 'validations' do
    subject(:region) { Fabricate.build(:region, name: 'Valid Region', nation: nation) }

    it { is_expected.to validate_presence_of(:name) } # From Geopolitocracy, re-affirmed by Region
    it { is_expected.to validate_presence_of(:nation) }
    # Slug presence and uniqueness are covered by Geopolitocracy concern

    context 'uniqueness of name scoped to nation_id' do
      before { Fabricate(:region, name: 'Duplicate Name Region', nation: nation) }
      let(:new_region) { Fabricate.build(:region, name: 'Duplicate Name Region', nation: nation) }

      it 'is invalid' do
        expect(new_region).not_to be_valid
        expect(new_region.errors[:name]).to include('must be unique within its nation')
      end
    end

    it 'allows same name in different nations' do
      other_nation = Fabricate(:nation, name: 'Otherland', abbr: 'OL')
      Fabricate(:region, name: 'Common Region Name', nation: nation)
      new_region_other_nation = Fabricate.build(:region, name: 'Common Region Name', nation: other_nation)
      expect(new_region_other_nation).to be_valid
    end

    context 'uniqueness of abbr scoped to nation_id (if abbr is present)' do
      before { Fabricate(:region, name: 'Region One', abbr: 'R1', nation: nation) }
      let(:new_region_dup_abbr) { Fabricate.build(:region, name: 'Region Two', abbr: 'R1', nation: nation) }
      let(:new_region_nil_abbr) { Fabricate.build(:region, name: 'Region Three', abbr: nil, nation: nation) }
      let(:new_region_diff_abbr) { Fabricate.build(:region, name: 'Region Four', abbr: 'R4', nation: nation) }

      it 'is invalid for duplicate abbr within the same nation' do
        expect(new_region_dup_abbr).not_to be_valid
        expect(new_region_dup_abbr.errors[:abbr]).to include('must be unique within its nation if provided')
      end

      it 'is valid if abbr is nil (another region can also have nil abbr)' do
        Fabricate(:region, name: 'Another Nil Abbr Region', abbr: nil, nation: nation)
        expect(new_region_nil_abbr).to be_valid
      end

      it 'is valid if abbr is different' do
        expect(new_region_diff_abbr).to be_valid
      end

      it 'allows same abbr in different nations' do
        other_nation = Fabricate(:nation, name: 'Otherlandia', abbr: 'OTL')
        Fabricate(:region, name: 'Region Alpha', abbr: 'RA', nation: nation)
        region_other_nation = Fabricate.build(:region, name: 'Region Beta', abbr: 'RA', nation: other_nation)
        expect(region_other_nation).to be_valid
      end
    end
  end

  describe '#to_s' do
    it 'returns the name of the region' do
      region = Fabricate.build(:region, name: 'My Awesome Region', nation: nation)
      expect(region.to_s).to eq('My Awesome Region')
    end
  end

  describe 'equality and comparison' do
    let(:region1_tl) { Fabricate(:region, name: 'Region Alpha', nation: nation, abbr: 'RA') }
    let(:region1_tl_again) { Region.find(region1_tl.id) } # Same object, different instance
    let(:region2_tl) { Fabricate(:region, name: 'Region Beta', nation: nation, abbr: 'RB') }
    let(:other_nation_obj) { Fabricate(:nation, name: 'OtherNation', abbr: 'ON') }
    let(:region1_on) { Fabricate(:region, name: 'Region Alpha', nation: other_nation_obj, abbr: 'RA') }

    context '#==' do
      it 'returns true for regions with the same nation_id and name' do
        expect(region1_tl == region1_tl_again).to be true
      end

      it 'returns false for regions with different names in the same nation' do
        expect(region1_tl == region2_tl).to be false
      end

      it 'returns false for regions with the same name but different nations' do
        expect(region1_tl == region1_on).to be false
      end

      it 'returns false when comparing with a non-Region object' do
        expect(region1_tl == 'not a region').to be false
      end
    end

    context '#<=>' do
      # Sorting is by nation.name, then region.name
      let(:nation_a) { Fabricate(:nation, name: 'Atlantis', abbr: 'AT') }
      let(:nation_z) { Fabricate(:nation, name: 'Zanzibar', abbr: 'ZN') }

      let(:region_at_beta)  { Fabricate(:region, name: 'Beta Province', nation: nation_a) }
      let(:region_at_gamma) { Fabricate(:region, name: 'Gamma State', nation: nation_a) }
      let(:region_zn_alpha) { Fabricate(:region, name: 'Alpha District', nation: nation_z) }

      let(:regions_for_sort) { [region_zn_alpha, region_at_gamma, region_at_beta] }
      let(:sorted_regions)   { [region_at_beta, region_at_gamma, region_zn_alpha] }

      it 'sorts regions based on their nation name, then region name' do
        expect(regions_for_sort.sort).to eq(sorted_regions)
      end

      it 'returns 0 if nation and name are the same' do
        # This implies they are the same record or an unsaved duplicate
        r1 = Fabricate.build(:region, name: 'Same Region', nation: nation)
        r2 = Fabricate.build(:region, name: 'Same Region', nation: nation)
        expect(r1 <=> r2).to eq(0)
      end

      it 'returns nil when comparing with a non-Region object' do
        expect(region1_tl <=> 'not a region').to be_nil
      end
    end
  end

  describe '.search (from Geopolitocracy)' do
    let!(:region1) { Fabricate(:region, name: 'North Province', nation: nation, slug: 'north-province', abbr: 'NP') }
    let!(:region2) { Fabricate(:region, name: 'South Province', nation: nation, slug: 'south-province', abbr: 'SP') }
    let!(:region3) { Fabricate(:region, name: 'South State', nation: nation, slug: 'south-state', abbr: 'SS') }

    it 'finds regions by slug prefix' do
      results = Region.search('North')
      expect(results).to include(region1)
      expect(results).not_to include(region2, region3)
    end

    it 'is case-insensitive' do
      results = Region.search('sOuTh')
      expect(results).to include(region2, region3)
    end

    it 'can perform an exact slug match' do
      exact_results = Region.search('north-province', exact: true)
      expect(exact_results.first).to eq(region1)
      expect(exact_results.count).to eq(1)

      partial_results = Region.search('north', exact: true)
      expect(partial_results.count).to eq(0)
    end
  end

  describe 'specific cases' do
    describe 'brasil' do
      let(:brasil) { Fabricate(:nation, name: 'Brasil', abbr: 'BR', phone: '55', postal: '00000-000') }
      let!(:rio_de_janeiro) { Fabricate(:region, name: 'Rio de Janeiro', nation: brasil, abbr: 'RJ') }
      let!(:rio_de_janeiro_city) { Fabricate(:city, name: 'Rio de Janeiro', nation: brasil, region: rio_de_janeiro) }

      it 'has Rio de Janeiro as regions and city' do
        expect(Region.where(nation: brasil).pluck(:name)).to include('Rio de Janeiro')
        expect(City.where(nation: brasil).pluck(:name)).to include('Rio de Janeiro')
      end

      it 'handles special characters in names' do
        geohash = {
          id: '1234567',
          name_translations: { 'en' => 'São Paulo', 'pt' => 'São Paulo' },
          abbr: 'SP', souls: 12_000_000, nation: brasil, code: '35'
        }
        region = Region.create(geohash)
        expect(region).to be_valid
        expect(region.slug).to eql('sao-paulo')
      end
    end

    describe 'argentina' do
      let(:argentina) { Fabricate(:nation, name: 'Argentina', abbr: 'AR', phone: '54', postal: 'C1000') }
      let!(:buenos_aires) { Fabricate(:region, name: 'Buenos Aires', nation: argentina, abbr: 'B') }
      let!(:cordoba) { Fabricate(:region, name: 'Córdoba', nation: argentina, abbr: 'C') }

      it 'has Buenos Aires and Córdoba as regions' do
        expect(Region.where(nation: argentina).pluck(:name)).to include('Buenos Aires', 'Córdoba')
      end

      it 'lots of terra del fuego' do
        geohash = {
          id: '3834450',
          name_translations: { 'en' => 'Tierra del Fuego', 'es' => 'Provincia de Tierra del Fuego ...' },
          abbr: 'T', souls: 190_641, nation: argentina, code: '23'
        }
        region = Region.create(geohash)
        expect(region).to be_valid
        expect(region.slug).to eql('tierra-del-fuego')
      end
    end
  end
end
