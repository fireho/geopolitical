require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Country do


  it { should have_many(:cities) }
  it { should have_many(:provinces) }

  it "should create a country" do
    blueprint_spec Country
  end

end






# == Schema Information
#
# Table name: countries
#
#  id   :integer         not null, primary key
#  name :string(50)      not null
#  abbr :string(3)       not null
#

