require 'spec_helper'

describe Nation, type: :model do
  it 'should create a nation' do
    expect { Nation.make! }.not_to raise_error
  end

  it 'should require an abbr' do
    expect(Nation.make(abbr: nil)).to_not be_valid
  end

  it 'should assign upcase abbr' do
    expect(Nation.make!(abbr: 'br').abbr).to eq('BR')
  end

  it 'should validates uniqueness of abbr' do
    Nation.make!(abbr: 'BR')
    expect(Nation.make(abbr: 'BR')).to_not be_valid
  end

  it 'should have abbr as _id' do
    Nation.make!(abbr: 'BR')
    expect(Nation.first[:_id]).to eq('BR')
  end

  it 'should have langs' do
    Nation.make!(abbr: 'BR', langs: %w(pt-BR es en))
    expect(Nation.first.langs.join(',')).to eq('pt-BR,es,en')
  end

  it 'should have lang' do
    Nation.make!(abbr: 'BR', lang: 'pt-BR')
    expect(Nation.first.lang).to eq('pt-BR')
  end

  it 'should have abbr as id' do
    Nation.make!(abbr: 'BR')
    expect(Nation.first.id).to eq('BR')
  end

  it 'should equal by abbr' do
    expect(Nation.new(abbr: 'BR')).to eq(Nation.new(abbr: 'BR'))
  end

  it 'may have a localized name' do
    I18n.locale = :'pt-BR'
    n = Nation.new(name: 'Brasil')
    expect(n.name).to eq('Brasil')
    I18n.locale = :en
    n.name = 'Brazil'
    expect(n.name_translations).to eq('pt-BR' => 'Brasil', 'en' => 'Brazil')
  end
end
