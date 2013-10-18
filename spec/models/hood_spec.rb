require 'spec_helper'

describe Hood do

  it 'should create a nation' do
    -> { Hood.make! }.should_not raise_error
  end

  it 'should belong to city' do
    Fabricate.build(:hood, city: nil).should have(1).error_on(:city)
  end

end
