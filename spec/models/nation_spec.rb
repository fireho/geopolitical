require 'spec_helper'

# Specs for the Nation model, covering its attributes, validations,
# associations, slug generation, and specific methods.
describe Nation, type: :model do
  describe 'fabrication' do
    it 'can be created with valid attributes' do
      # Assumes the default fabricator creates a valid nation
      expect { Fabricate(:nation) }.not_to raise_error
    end

    it 'is valid with a name and abbr' do
      nation = Fabricate.build(:nation, name: 'Testland', abbr: 'TL')
      expect(nation).to be_valid
    end
  end

  describe 'attributes and defaults' do
    subject(:nation) { Fabricate.build(:nation, name: 'Utopia', abbr: 'UT') }

    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:abbr) }
    it { is_expected.to respond_to(:slug) } # From Geopolitocracy
    it { is_expected.to respond_to(:gid) }
    it { is_expected.to respond_to(:tld) }
    it { is_expected.to respond_to(:cash) }
    it { is_expected.to respond_to(:currency) } # Alias for cash
    it { is_expected.to respond_to(:code3) }
    it { is_expected.to respond_to(:lang) }
    it { is_expected.to respond_to(:langs) }
    it { is_expected.to respond_to(:pop) } # From Geopolitocracy

    it 'defaults _id to its abbreviation' do
      nation.valid? # Trigger callbacks
      # Note: `abbr` is uppercased by the setter.
      # `_id` default uses the (potentially modified) `abbr` value.
      expect(nation._id).to eq('UT')
      expect(nation.id).to eq('UT')
    end

    it 'defaults langs to an empty array' do
      expect(Nation.new.langs).to eq([])
    end

    context 'aliases' do
      it 'aliases currency to cash' do
        nation.cash = '$'
        expect(nation.currency).to eq('$')
        nation.currency = '€'
        expect(nation.cash).to eq('€')
      end

      it 'aliases iso_3166_3 to code3' do
        nation.code3 = 'UTO'
        expect(nation.code3).to eq('UTO')
      end
    end
  end

  describe 'validations' do
    subject(:nation) { Fabricate.build(:nation, name: 'Validland', abbr: 'VL') }

    it { is_expected.to validate_presence_of(:name) } # From Nation model
    it { is_expected.to validate_presence_of(:abbr) } # From Nation model
    it {
      is_expected.to validate_uniqueness_of(:abbr).case_insensitive
    } # Mongoid default is case sensitive, but setter upcases
    it { is_expected.to validate_presence_of(:slug) } # From Geopolitocracy
    it { is_expected.to validate_uniqueness_of(:slug) } # From Geopolitocracy

    it 'requires abbr to be present' do
      nation.abbr = nil
      expect(nation).not_to be_valid
      expect(nation.errors[:abbr]).to include("can't be blank")
    end

    it 'validates uniqueness of abbr (case is handled by setter)' do
      Fabricate(:nation, name: 'Firstland', abbr: 'FL')
      duplicate_nation = Fabricate.build(:nation, name: 'Secondland', abbr: 'fl') # Will be upcased to FL
      expect(duplicate_nation).not_to be_valid
      expect(duplicate_nation.errors[:abbr]).to include('has already been taken')
    end

    it 'requires name to be present' do
      nation.name = nil
      expect(nation).not_to be_valid
      expect(nation.errors[:name]).to include("can't be blank in en")
    end
  end

  describe '#abbr=' do
    let(:nation) { Fabricate.build(:nation, name: 'Test Nation') }

    it 'upcases the assigned abbreviation' do
      nation.abbr = 'br'
      expect(nation.abbr).to eq('BR')
    end

    it 'handles nil input gracefully' do
      nation.abbr = nil
      expect(nation.abbr).to be_nil
    end
  end

  describe 'slug generation (from Geopolitocracy)' do
    it 'creates a slug from the name' do
      nation = Fabricate.build(:nation, name: 'New Republic', abbr: 'NR')
      nation.valid? # Trigger callbacks
      expect(nation.slug).to eq('new-republic')
    end

    it 'handles names with special characters for slug' do
      nation = Fabricate.build(:nation, name: 'République Française!', abbr: 'FR')
      nation.valid?
      expect(nation.slug).to eq('republique-francaise')
    end
  end

  describe 'language fields' do
    it 'can store multiple official languages' do
      nation = Fabricate(:nation, name: 'Polyglottia', abbr: 'PG', langs: %w[en fr es])
      expect(nation.langs).to match_array(%w[en fr es])
    end

    it 'can store a primary language' do
      nation = Fabricate(:nation, name: 'Lingua Franca', abbr: 'LF', langs: ['eo'])
      expect(nation.lang).to eq('eo')
    end
  end

  describe 'associations' do
    subject { Fabricate.build(:nation) }

    it { is_expected.to belong_to(:capital).of_type(City).with_optional }
    it { is_expected.to have_many(:regions).with_dependent(:destroy) }
    it { is_expected.to have_many(:cities).with_dependent(:destroy) }
  end

  describe '#planet' do
    it 'returns :earth' do
      expect(Fabricate.build(:nation).planet).to eq(:earth)
    end
  end

  describe 'equality and comparison' do
    let(:nation_br1) { Fabricate.build(:nation, name: 'Brazil', abbr: 'BR') }
    # To test equality, abbr must be identical after setter logic
    let(:nation_br2) { Fabricate.build(:nation, name: 'Brasil', abbr: 'br') } # abbr becomes 'BR'
    let(:nation_ar)  { Fabricate.build(:nation, name: 'Argentina', abbr: 'AR') }
    let(:nation_br_diff_name) { Fabricate.build(:nation, name: 'Federative Republic of Brazil', abbr: 'BR') }

    context '#==' do
      it 'returns true for nations with the same abbreviation' do
        expect(nation_br1 == nation_br2).to be true
      end

      it 'returns false for nations with different abbreviations' do
        expect(nation_br1 == nation_ar).to be false
      end

      it 'returns false when comparing with a non-Nation object' do
        expect(nation_br1 == 'not a nation').to be false
      end
    end

    context '#<=>' do
      # Sorting is by name
      let(:nations_for_sort) do
        [
          Fabricate.build(:nation, name: 'Canada', abbr: 'CA'),
          Fabricate.build(:nation, name: 'Argentina', abbr: 'AR'),
          Fabricate.build(:nation, name: 'Brazil', abbr: 'BR')
        ]
      end
      let(:sorted_nations_by_name) do
        [
          nations_for_sort[1], # Argentina
          nations_for_sort[2], # Brazil
          nations_for_sort[0]  # Canada
        ]
      end

      it 'sorts nations based on their names' do
        expect(nations_for_sort.sort).to eq(sorted_nations_by_name)
      end

      it 'returns 0 if names are the same' do
        # Ensure abbr is different for these to be distinct valid records if saved
        n1 = Fabricate.build(:nation, name: 'Same Name', abbr: 'S1')
        n2 = Fabricate.build(:nation, name: 'Same Name', abbr: 'S2')
        expect(n1 <=> n2).to eq(0)
      end

      it 'returns nil when comparing with a non-Nation object' do
        expect(nation_br1 <=> 'not a nation').to be_nil
      end
    end
  end

  describe 'localized name (from Geopolitocracy)' do
    subject(:nation) { Fabricate.build(:nation, abbr: 'LN') } # Localized Nation

    around do |example|
      original_locale = I18n.locale
      I18n.available_locales = %i[en pt-BR fr]
      example.run
      I18n.locale = original_locale
      I18n.available_locales = %i[en] # Reset
    end

    it 'can store and retrieve localized names' do
      I18n.with_locale(:'pt-BR') { nation.name = 'Brasil' }
      I18n.with_locale(:en)      { nation.name = 'Brazil' }
      I18n.with_locale(:fr)      { nation.name = 'Brésil' }

      I18n.with_locale(:'pt-BR') { expect(nation.name).to eq('Brasil') }
      I18n.with_locale(:en)      { expect(nation.name).to eq('Brazil') }
      I18n.with_locale(:fr)      { expect(nation.name).to eq('Brésil') }

      expect(nation.name_translations).to eq({
                                               'pt-BR' => 'Brasil',
                                               'en' => 'Brazil',
                                               'fr' => 'Brésil'
                                             })
    end
  end

  describe '.search (from Geopolitocracy)' do
    let!(:nation1) { Fabricate(:nation, name: 'United States', abbr: 'US', slug: 'united-states') }
    let!(:nation2) { Fabricate(:nation, name: 'United Kingdom', abbr: 'UK', slug: 'united-kingdom') }
    let!(:nation3) { Fabricate(:nation, name: 'Canada', abbr: 'CA', slug: 'canada') }

    it 'finds nations by slug prefix' do
      results = Nation.search('United')
      expect(results).to include(nation1, nation2)
      expect(results).not_to include(nation3)
    end

    it 'is case-insensitive' do
      results = Nation.search('uNiTeD')
      expect(results).to include(nation1, nation2)
    end

    it 'can perform an exact slug match' do
      exact_results = Nation.search('united-states', true)
      expect(exact_results.first).to eq(nation1)
      expect(exact_results.count).to eq(1)

      partial_results = Nation.search('united', true)
      expect(partial_results.count).to eq(0)
    end
  end
end
