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

  it 'should accept area phone code modified regex' do
    expect(Hood.make(phone: '115555XXXX')).to be_valid
  end

  it 'should accept area postal code modified regex' do
    expect(Hood.make(postal: '15123123')).to be_valid
  end
end
