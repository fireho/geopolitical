require 'spec_helper'

describe Hood do

  it { should be_green }

  it "should belong to city" do
    Fabricate.build(:hood, :city => nil).should have(1).error_on(:city)
  end

  it "should respond with hookers" do
    Hood.new.ads.should be_empty
  end

end
