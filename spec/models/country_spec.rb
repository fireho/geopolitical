require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Nation do


  it { should have_many(:cities) }
  it { should have_many(:regions) }

  it "should create a nation" do
    blueprint_spec Nation
  end

end






# == Schema Information
#
# Table name: nations
#
#  id   :integer         not null, primary key
#  name :string(50)      not null
#  abbr :string(3)       not null
#
