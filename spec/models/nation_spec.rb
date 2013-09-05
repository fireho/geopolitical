require 'spec_helper'

describe Nation do


  it "should create a nation" do
    lambda {  Nation.make! }.should_not raise_error
  end



end
