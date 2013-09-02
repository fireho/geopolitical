require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Province do

  it { should belong_to(:country) }
  it { should have_many(:cities) }

  it "should create a province" do
    blueprint_spec Province
  end

end



