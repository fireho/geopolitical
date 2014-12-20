require 'spec_helper'

describe Region, type: :model do
  it 'should create a region' do
    expect { Region.make! }.not_to raise_error
  end

  it 'should create it\'s own slug' do
    city = Region.create(name: 'Amapá')
    expect(city.slug).to eq('amapa')
  end
end
