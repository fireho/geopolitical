require 'spec_helper'

describe Nation, :type => :model do

  it 'should create a nation' do
    expect {  Nation.make! }.not_to raise_error
  end

  it 'should require an abbr' do
    expect(Nation.make(abbr: nil)).to have(1).error_on(:abbr)
  end

  it 'should validates uniqueness of abbr' do
    Nation.make!(abbr: 'BR')
    expect(Nation.make(abbr: 'BR')).to have(1).error_on(:abbr)
  end

  it 'should have abbr as _id' do
    Nation.make!(abbr: 'BR')
    expect(Nation.first[:_id]).to eq('BR')
  end

  it 'may have a localized name' do
    I18n.locale = :pt
    n = Nation.new(name: 'Brasil')
    expect(n.name).to eq('Brasil')
    I18n.locale = :en
    n.name = 'Brazil'
    expect(n.name_translations).to eq('pt' => 'Brasil', 'en' => 'Brazil')
  end

end
