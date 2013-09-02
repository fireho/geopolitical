require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Region do

  it { should belong_to(:country) }
  it { should have_many(:cities) }

  it "should create a region" do
    blueprint_spec Region
  end

end
