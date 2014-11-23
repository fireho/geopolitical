require 'spec_helper'

describe Hood, :type => :model do

  it 'should create a nation' do
    expect { Hood.make! }.not_to raise_error
  end

  it 'should belong to city' do
    expect(Fabricate.build(:hood, city: nil).error_on(:city).size).to eq(1)
  end

end
