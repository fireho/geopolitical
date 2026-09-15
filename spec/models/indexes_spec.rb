# frozen_string_literal: true

require 'spec_helper'

# A uniqueness validation is a read-then-write: under concurrency it is a
# suggestion. These insert straight into the collection, past the validation,
# so only the index can say no.
describe 'unique indexes back the uniqueness validations' do
  before { [Nation, Region, City, Hood].each(&:create_indexes) }

  def raw(model, doc) = model.collection.insert_one(doc)

  it 'builds every declared index, none silently dropped by a duplicate key' do
    [Nation, Region, City, Hood].each do |model|
      live = model.collection.indexes.map { |i| i['key'].to_h }
      declared = model.index_specifications.map { |s| s.key.transform_keys(&:to_s) }
      expect(live).to include(*declared)
    end
  end

  it 'refuses a second nation with the same abbr' do
    raw(Nation, _id: 'X1', abbr: 'BR', slug: 'brasil')
    expect { raw(Nation, _id: 'X2', abbr: 'BR', slug: 'brasil-2') }
      .to raise_error(Mongo::Error::OperationFailure, /E11000/)
  end

  describe Region do
    let(:br) { Nation.create!(name: 'Brasil', abbr: 'BR') }

    it 'lets many abbr-less regions live in one nation' do
      Region.create!(name: 'Norte', nation: br)
      expect(Region.create!(name: 'Sul', nation: br)).to be_persisted
      expect { raw(Region, nation_id: br.id, name: 'Leste', slug: 'leste', abbr: '') }.not_to raise_error
    end

    it 'refuses a second region with the same abbr in one nation' do
      raw(Region, nation_id: br.id, name: 'São Paulo', slug: 'sao-paulo', abbr: 'SP')
      expect { raw(Region, nation_id: br.id, name: 'Sampa', slug: 'sampa', abbr: 'SP') }
        .to raise_error(Mongo::Error::OperationFailure, /E11000/)
    end
  end

  describe City do
    let(:br) { Nation.create!(name: 'Brasil', abbr: 'BR') }
    let(:sp) { Region.create!(name: 'São Paulo', abbr: 'SP', nation: br) }
    let(:mg) { Region.create!(name: 'Minas Gerais', abbr: 'MG', nation: br) }

    it 'refuses a second city with the same name in one region' do
      raw(City, nation_id: br.id, region_id: sp.id, name: { 'en' => 'Guaíra' }, slug: 'guaira-sp')
      expect { raw(City, nation_id: br.id, region_id: sp.id, name: { 'en' => 'Guaíra' }, slug: 'guaira-sp-2') }
        .to raise_error(Mongo::Error::OperationFailure, /E11000/)
    end

    # `spatial: true` plus an explicit 2dsphere used to give geom two indexes,
    # and `nearby` picked the planar one. One index, spherical, like every
    # Whereabouts geom in the fleet.
    it 'indexes geom once, as 2dsphere' do
      geo = City.index_specifications.map(&:key).select { |key| key.key?(:geom) }
      expect(geo).to eq([{ geom: '2dsphere' }])
    end

    it 'keeps the same name in two regions' do
      City.create!(name: 'Guaíra', region: sp, nation: br)
      expect(City.create!(name: 'Guaíra', region: mg, nation: br)).to be_persisted
    end
  end
end
