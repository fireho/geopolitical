require 'spec_helper'

describe Nation do

  it 'should create a nation' do
    -> {  Nation.make! }.should_not raise_error
  end

  it 'should require an abbr' do
    Nation.make(abbr: nil).should have(1).error_on(:abbr)
  end

  it 'should validates uniqueness of abbr' do
    Nation.make!(abbr: 'BR')
    Nation.make(abbr: 'BR').should have(1).error_on(:abbr)
  end

  it 'should have abbr as _id' do
    Nation.make!(abbr: 'BR')
    Nation.first[:_id].should eq('BR')
  end

  it 'may have a localized name' do
    I18n.locale = :pt
    n = Nation.new(name: 'Brasil')
    n.name.should eq('Brasil')
    I18n.locale = :en
    n.name = 'Brazil'
    n.name_translations.should eq('pt' => 'Brasil', 'en' => 'Brazil')
  end

end
