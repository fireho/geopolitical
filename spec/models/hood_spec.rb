require 'spec_helper'

describe Hood, type: :model do
  it 'should create a nation' do
    expect { Hood.make! }.not_to raise_error
  end

  it 'should belong to city' do
    expect(Hood.make(city: nil)).to_not be_valid
  end

  it 'should not  to city' do
    expect(Hood.make(city: nil)).to_not be_valid
  end

  it 'should have a name' do
    expect(Hood.make(name: '')).to_not be_valid
  end

  it 'should have a name' do
    expect(Hood.make(name: nil)).to_not be_valid
  end

  it 'should have city slug' do
    city = City.make!(name: 'Gotham')
    hood = Hood.make(name: 'JD. ITALIA', city: city).tap(&:save)
    expect(hood.slug).to eq('gotham-jd-italia')
  end

  it 'should titleize name' do
    expect(Hood.make(name: 'JD. ITALIA').name).to eq('Jd. Italia')
  end

  it 'should not have dup name in city' do
    city = City.make!(name: 'Gotham')
    expect(Hood.make!(name: 'Bowery', city: city)).to be_valid
    expect(Hood.make(name: 'Bowery', city: city)).to_not be_valid
  end

  it 'should accept area phone code modified regex' do
    expect(Hood.make(phone: '115555XXXX')).to be_valid
  end

  it 'should accept area postal code modified regex' do
    expect(Hood.make(postal: '15123123')).to be_valid
  end
end
