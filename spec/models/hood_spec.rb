require 'spec_helper'

describe Hood, :type => :model do

  it 'should create a nation' do
    expect { Hood.make! }.not_to raise_error
  end

  it 'should belong to city' do
    expect(Hood.make(city: nil)).to_not be_valid
  end

end
