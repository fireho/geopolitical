require 'spec_helper'

describe Region do

  it 'should create a region' do
    -> {  Region.make! }.should_not raise_error
  end

end
