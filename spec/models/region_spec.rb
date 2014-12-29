require 'spec_helper'

describe Region, type: :model do
  it 'should create a region' do
    expect { Region.make! }.not_to raise_error
  end

  it 'should create it\'s own slug' do
    city = Region.create(name: 'Amapá')
    expect(city.slug).to eq('amapa')
  end

  it 'should accept area phone code modified regex' do
    expect(Region.make(phone: '88XXXXXXXX')).to be_valid
  end

  it 'should accept area postal code modified regex' do
    expect(Region.make(postal: '15XXXXXX')).to be_valid
  end
end
