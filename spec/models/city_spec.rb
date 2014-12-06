# -*- coding: utf-8 -*-
require 'spec_helper'

describe City, type: :model do

  it 'should create a city' do
    expect { City.make! }.not_to raise_error
  end

  it 'should accept some params and utf8' do
    city = City.create(name: 'Patópolis', slug: 'patopolis', souls: 100_000)
    expect(city).to be_valid
  end

  describe 'instance' do

    let(:city) { City.make! }

    describe 'Relatives' do
      let(:nation) { Nation.make! }

      it 'should belongs to nation' do
        city.nation = nation
        expect(city.save).to be_truthy
      end

      it 'should belongs to region' do
        city.nation = nation
        expect(city.save).to be_truthy
      end

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

    it 'should have a slug' do
      city = City.new(name: '')

      city.save
      expect(city).not_to be_valid
      # expect(city).to have(1).errors_on(:slug)
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
