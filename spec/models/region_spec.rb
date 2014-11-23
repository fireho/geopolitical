require 'spec_helper'

describe Region, :type => :model do

  it 'should create a region' do
    expect {  Region.make! }.not_to raise_error
  end

end
