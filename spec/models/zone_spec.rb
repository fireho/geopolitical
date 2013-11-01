require 'spec_helper'

describe Zone do

  it 'should create a region' do
    -> {  Zone.make! }.should_not raise_error
  end

  describe 'instance' do

    let(:zone) { Zone.make!(name: 'Coffee Makers') }

    it "should have a polymorphic relantionship with others" do
      zone.members.create(member: Nation.make!(name: "Brasil"))
      zone.should have(1).member
      Zone::Member.count.should eq(1)
    end


  end

end
