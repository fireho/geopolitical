require 'spec_helper'

# Specs for the Hood model, covering its attributes, validations,
# associations, slug generation, and helper methods.
describe Hood, type: :model do
  let!(:nation) { Fabricate(:nation, name: 'Testlandia', abbr: 'TL') }
  let!(:region) { Fabricate(:region, name: 'Test Region', abbr: 'TR', nation: nation) }
  let!(:city)   { Fabricate(:city, name: 'Metroville', region: region, nation: nation, slug: 'metroville-tr') } # City slug is metroville-tr

  describe 'fabrication' do
    it 'can be created with valid attributes' do
      # Assumes the default fabricator creates a valid hood with a city
      expect { Fabricate(:hood, city: city) }.not_to raise_error
    end

    it 'is valid with a name and city' do
      hood = Fabricate.build(:hood, name: 'Downtown', city: city)
      expect(hood).to be_valid
    end
  end

  describe 'attributes and defaults' do
    subject(:hood) { Fabricate.build(:hood, name: 'Suburbia', city: city) }

    it { is_expected.to respond_to(:name) } # From Geopolitocracy
    it { is_expected.to respond_to(:abbr) } # From Geopolitocracy
    it { is_expected.to respond_to(:slug) } # From Geopolitocracy
    it { is_expected.to respond_to(:pop) }  # From Geopolitocracy
    it { is_expected.to respond_to(:phone) } # Own method, also field from Geopolitocracy
    it { is_expected.to respond_to(:postal) }# Own method, also field from Geopolitocracy
    it { is_expected.to respond_to(:rank) }
  end

  describe 'slug generation' do
    # Hood's ensure_slug calls super (Geopolitocracy's) then modifies it.
    # Geopolitocracy's ensure_slug_is_generated sets slug = name.parameterize if slug is blank.
    # Hood's ensure_slug then prepends city.slug.

    it 'generates a slug as "city.slug-hood.name.parameterize"' do
      hood = Fabricate.build(:hood, name: 'Jd. Italia', city: city) # city.slug is 'metroville-tr'
      hood.valid? # Trigger callbacks
      expect(hood.slug).to eq('metroville-tr-jd-italia')
    end

    it 'handles existing simple slug from Geopolitocracy and prepends city slug' do
      hood = Fabricate.build(:hood, name: 'Old District', city: city)
      # Simulate Geopolitocracy's ensure_slug_is_generated running first
      allow(hood).to receive(:super) do # Mock the call to Geopolitocracy's ensure_slug
        hood.slug = 'old-district' # What Geopolitocracy might set it to
      end
      hood.ensure_slug # Call Hood's specific ensure_slug
      expect(hood.slug).to eq('metroville-tr-old-district')
    end

    it 'handles existing complex slug (already containing city slug) correctly by not re-prepending' do
       hood = Fabricate.build(:hood, name: 'Park Side', city: city)
       hood.slug = 'metroville-tr-park-side' # Slug is already correctly formatted
       hood.ensure_slug # Call Hood's specific ensure_slug
       expect(hood.slug).to eq('metroville-tr-park-side') # Should not change
    end


    it 'handles names with special characters for the hood part of the slug' do
      hood = Fabricate.build(:hood, name: 'The "Heights" & Co.', city: city)
      hood.valid?
      expect(hood.slug).to eq('metroville-tr-the-heights-co')
    end

    it 'handles blank hood name gracefully (slug might become just city slug or city-slug-)' do
      hood = Fabricate.build(:hood, name: '', city: city)
      hood.valid?
      # Depending on parameterize behavior with blank string, could be 'metroville-tr' or 'metroville-tr-'
      # The current Hood#ensure_slug logic: `city.slug}-#{parameterized_name}`. If parameterized_name is empty, it becomes `city.slug}-`
      # Geopolitocracy's slug validation will likely fail this due to presence or format.
      expect(hood.slug).to eq("metroville-tr-") # or just city.slug if parameterized_name.blank? is checked
      expect(hood).not_to be_valid # Name is required by Geopolitocracy
      expect(hood.errors[:name]).to include("can't be blank")
    end
  end

  describe 'name titleization (from Geopolitocracy)' do
    it 'titleizes the name on assignment' do
      hood = Fabricate.build(:hood, name: 'lower east side', city: city)
      expect(hood.name).to eq('Lower East Side')
    end

    it 'does not re-titleize an already titleized or mixed-case name' do
      hood = Fabricate.build(:hood, name: 'SoHo District', city: city)
      expect(hood.name).to eq('SoHo District')
    end
  end

  describe 'contact info fallbacks' do
    let(:city_with_contacts) { Fabricate(:city, name: 'Contact City', nation: nation, phone: '0123', postal: 'CITYPOST') }
    let(:hood_only) { Fabricate.build(:hood, name: 'HoodOnly', city: city_with_contacts) }
    let(:hood_with_own) { Fabricate.build(:hood, name: 'HoodOwn', phone: '9876', postal: 'HOODPOST', city: city_with_contacts) }

    context '#phone' do
      it 'returns own phone if present' do
        expect(hood_with_own.phone).to eq('9876')
      end
      it 'falls back to city phone' do
        hood_only.phone = nil # Ensure hood's own phone is nil
        expect(hood_only.phone).to eq('0123')
      end
      it 'returns nil if own and city phone are nil' do
        city_with_contacts.phone = nil
        hood_only.phone = nil
        expect(hood_only.phone).to be_nil
      end
    end

    context '#postal' do
      it 'returns own postal if present' do
        expect(hood_with_own.postal).to eq('HOODPOST')
      end
      it 'falls back to city postal' do
        hood_only.postal = nil
        expect(hood_only.postal).to eq('CITYPOST')
      end
      it 'returns nil if own and city postal are nil' do
        city_with_contacts.postal = nil
        hood_only.postal = nil
        expect(hood_only.postal).to be_nil
      end
    end
  end

  describe 'associations' do
    subject { Fabricate.build(:hood, city: city) }
    it { is_expected.to belong_to(:city) }
  end

  describe 'validations' do
    subject(:hood) { Fabricate.build(:hood, name: 'Valid Hood', city: city) }

    it { is_expected.to validate_presence_of(:name) } # From Geopolitocracy
    it { is_expected.to validate_presence_of(:city) }
    # Slug presence and uniqueness are covered by Geopolitocracy concern

    context 'uniqueness of name scoped to city_id' do
      before { Fabricate(:hood, name: 'Duplicate Name Hood', city: city) }
      let(:new_hood) { Fabricate.build(:hood, name: 'Duplicate Name Hood', city: city) }

      it 'is invalid' do
        expect(new_hood).not_to be_valid
        expect(new_hood.errors[:name]).to include("must be unique within its city")
      end
    end

    it 'allows same name in different cities' do
      other_city = Fabricate(:city, name: 'Otherville', nation: nation)
      Fabricate(:hood, name: 'Common Hood Name', city: city)
      new_hood_other_city = Fabricate.build(:hood, name: 'Common Hood Name', city: other_city)
      expect(new_hood_other_city).to be_valid
    end

    it 'requires city to be present' do
      hood.city = nil
      expect(hood).not_to be_valid
      expect(hood.errors[:city]).to include("can't be blank")
    end
  end

  describe '#to_s' do
    it 'returns the name of the hood' do
      hood = Fabricate.build(:hood, name: 'The Village', city: city)
      expect(hood.to_s).to eq('The Village')
    end
  end

  describe '#as_json' do
    let(:hood) { Fabricate(:hood, name: 'Json Hood', city: city, rank: 5) }
    subject { hood.as_json }

    it 'includes id as string' do
      expect(subject[:id]).to eq(hood._id.to_s)
    end
    it 'includes name' do
      expect(subject[:name]).to eq('Json Hood')
    end
    it 'includes city_id as string' do
      expect(subject[:city_id]).to eq(city.id.to_s)
    end
    it 'includes city_slug' do
      expect(subject[:city_slug]).to eq(city.slug)
    end
    # Rank is not in the current as_json, but could be added.
    # it { is_expected.to include(rank: 5) }
  end


  describe 'equality and comparison' do
    let(:hood1_cityA) { Fabricate(:hood, name: 'Hood Alpha', city: city) }
    let(:hood1_cityA_again) { Hood.find(hood1_cityA.id) }
    let(:hood2_cityA) { Fabricate(:hood, name: 'Hood Beta', city: city) }

    let(:other_city_obj) { Fabricate(:city, name: 'Other City', nation: nation) }
    let(:hood1_cityB) { Fabricate(:hood, name: 'Hood Alpha', city: other_city_obj) }

    context '#==' do
      it 'returns true for hoods with the same city_id and name' do
        expect(hood1_cityA == hood1_cityA_again).to be true
      end

      it 'returns false for hoods with different names in the same city' do
        expect(hood1_cityA == hood2_cityA).to be false
      end

      it 'returns false for hoods with the same name but different cities' do
        expect(hood1_cityA == hood1_cityB).to be false
      end

      it 'returns false when comparing with a non-Hood object' do
        expect(hood1_cityA == "not a hood").to be false
      end
    end

    context '#<=>' do
      # Sorting is by city.slug (or name), then hood.name
      let(:city_X) { Fabricate(:city, name: 'Xanadu City', slug: 'xanadu-city', nation: nation) }
      let(:city_Y) { Fabricate(:city, name: 'York Town', slug: 'york-town', nation: nation) }

      let(:hood_XA_beta)  { Fabricate(:hood, name: 'Beta Block', city: city_X) }
      let(:hood_XA_gamma) { Fabricate(:hood, name: 'Gamma Gardens', city: city_X) }
      let(:hood_YB_alpha) { Fabricate(:hood, name: 'Alpha Avenue', city: city_Y) }

      let(:hoods_for_sort) { [hood_YB_alpha, hood_XA_gamma, hood_XA_beta] }
      # Expected sort: city_X/Beta, city_X/Gamma, city_Y/Alpha
      let(:sorted_hoods)   { [hood_XA_beta, hood_XA_gamma, hood_YB_alpha] }


      it 'sorts hoods based on their city slug/name, then hood name' do
        # Ensure slugs are generated for cities if not explicitly set in fabricator
        [city_X, city_Y].each(&:valid?)
        expect(hoods_for_sort.sort).to eq(sorted_hoods)
      end

      it 'returns 0 if city and name are the same' do
        h1 = Fabricate.build(:hood, name: 'Same Hood', city: city)
        h2 = Fabricate.build(:hood, name: 'Same Hood', city: city)
        expect(h1 <=> h2).to eq(0)
      end

      it 'returns nil when comparing with a non-Hood object' do
        expect(hood1_cityA <=> "not a hood").to be_nil
      end
    end
  end

  describe '.search (from Geopolitocracy)' do
    let!(:hood1) { Fabricate(:hood, name: 'Green Valley', city: city) } # slug: metroville-tr-green-valley
    let!(:hood2) { Fabricate(:hood, name: 'Greenwood Park', city: city) }# slug: metroville-tr-greenwood-park
    let!(:hood3) { Fabricate(:hood, name: 'Blue Bay', city: city) }      # slug: metroville-tr-blue-bay

    before do # Ensure slugs are generated
      [hood1, hood2, hood3].each(&:save!)
    end

    it 'finds hoods by slug prefix (which includes city slug)' do
      # Search for "metroville-tr-green"
      results = Hood.search('metroville-tr-green')
      expect(results).to include(hood1, hood2)
      expect(results).not_to include(hood3)
    end

    it 'finds hoods by just hood name part if city slug is complex' do
        # This tests Geopolitocracy's search, which is on the full slug.
        # To search just by hood name, one might need a more complex query or custom search.
        results_by_hood_name_only = Hood.where(slug: /green/) # A direct regex on slug
        expect(results_by_hood_name_only).to include(hood1, hood2)


        # Geopolitocracy's search will parameterize "Green" to "green"
        # and search for slugs starting with "green". This won't match "metroville-tr-green..."
        results_geopolitocracy_search = Hood.search('Green')
        expect(results_geopolitocracy_search.count).to eq(0) # Because no slug starts with just "green"
    end


    it 'is case-insensitive for the search term' do
      results = Hood.search('MeTrOvIlLe-Tr-GrEeN')
      expect(results).to include(hood1, hood2)
    end

    it 'can perform an exact slug match' do
      exact_results = Hood.search('metroville-tr-green-valley', true)
      expect(exact_results.first).to eq(hood1)
      expect(exact_results.count).to eq(1)

      partial_results = Hood.search('metroville-tr-green', true) # Not an exact match
      expect(partial_results.count).to eq(0)
    end
  end
end
