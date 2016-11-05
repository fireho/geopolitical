# -*- coding: utf-8 -*-
require 'spec_helper'

describe City, type: :model do
  it 'should create a city' do
    expect { City.make! }.not_to raise_error
  end

  it 'should accept some params and utf8' do
    city = City.make(name: 'Patópolis', slug: 'patopolis', souls: 100_000)
    expect(city).to be_valid
  end

  it 'should create it\'s own slug' do
    city = City.create(name: 'Patópolis', souls: 100_000)
    expect(city.slug).to eq('patopolis')
  end

  it 'should avoid dots it\'s own slug' do
    expect(City.create(name: 'Mte. Sto. de MG').slug).to eq('mte-sto-de-mg')
  end

  it 'should append region abbr if it\'s a dup' do
    sp = Region.make(abbr: 'SP')
    mg = Region.make(abbr: 'MG')
    city1 = City.create(name: 'Patópolis', souls: 100_000, region: sp)
    expect(city1.slug).to eq('patopolis')
    city2 = City.create(name: 'Patópolis', souls: 100_000, region: mg)
    expect(city2.slug).to eq('patopolis-mg')
  end

  it 'should accept area phone code modified regex' do
    expect(City.make(phone: '3555XXXX')).to be_valid
  end

  it 'should accept area postal code modified regex' do
    expect(City.make(postal: '15123XXX')).to be_valid
  end

  it 'should be searchable' do
    city = City.make!(name: 'São Paulo')
    expect(City.search('sao paulo').first).to eq(city)
  end

  it 'should print nicely in #to_s' do
    city = City.make(name: 'Ibitim', region: Region.make(abbr: 'MG'))
    expect(city.to_s).to eq('Ibitim/MG')
  end

  it 'should print nicely in #to_s' do
    region = Region.make(name: 'Acre', abbr: nil)
    city = City.make(name: 'Ibitim', region: region)
    expect(city.to_s).to eq('Ibitim/Acre')
  end

  it 'should print nicely in #with_region' do
    region = Region.make(name: 'Acre', abbr: 'AC')
    city = City.make(name: 'Ibitim', region: region)
    expect(city.to_s).to eq('Ibitim/AC')
  end

  it 'should print nicely #with_nation' do
    nation = Nation.make(abbr: 'BR')
    region = Region.make(abbr: 'MG', nation: nation)
    city = City.make(name: 'Ibitim', region: region, nation: nation)
    expect(city.with_nation).to eq('Ibitim/MG/BR')
  end

  describe 'instance' do
    let(:nation) { Nation.make! }
    let(:city) { City.make! }

    it 'should belongs to nation' do
      city.nation = nation
      expect(city.save).to be_truthy
    end

    it 'should belongs to region' do
      city.nation = nation
      expect(city.save).to be_truthy
    end
  end

  describe 'geoenabled' do
    before do
      City.create_indexes
    end

    it 'should find closest one' do
      city = City.make!
      expect(City.nearby(city.geom).first).to eql(city)
    end
  end

  describe 'validations' do
    it 'should have a name' do
      expect(City.new(name: '')).not_to be_valid
    end
  end

  describe 'sorting' do
    let(:cities) do
      [City.make!(name: 'Abadia', souls: 500),
       City.make!(name: 'Xangrilá', souls: 5000)]
    end

    it 'should sort by name' do
      expect(City.ordered).to eq cities
    end

    it 'should sort by pop' do
      expect(City.population).to eq cities.reverse
    end
  end
end

#   it { should have_indices :name, :geom, :area, [:region_id, :nation_id] }

#   it 'should accept an area' do
#     @city = City.make(:area =>  Polygon.from_coordinates([
#     [[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]]))
#     @city.area.should be_instance_of(Polygon)
#   end

#   describe 'some helpers' do
#     it 'should have some nice x y z' do
#       @city = City.make
#       @city.should respond_to(:x,:y,:z)
#     end
#   end

#   describe 'Find by proximity' do

#     def pt(x,y);      Point.from_x_y(x,y); end

#     before(:each) do
#       @perto = City.make!(:geom => pt(10,10))
#       @medio = City.make!(:geom => pt(20,20))
#       @longe = City.make!(:geom => pt(30,30))
#       @ponto = pt(12,12)
#     end

#     it 'should find the closest city' do
#       @city = City.close_to(@ponto).first
#       @city.should eql(@perto)
#     end

#     it 'should find the closest city to make sure' do
#       ponto = pt(22,22)
#       @city = City.close_to(ponto).first
#       @city.should eql(@medio)
#     end

#     it 'should find the closest' do
#       @poi = City.close_to(@ponto).first(2)
#       @poi.should eql([@perto,@medio])
#     end
#   end
