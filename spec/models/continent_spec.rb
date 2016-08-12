require 'spec_helper'

describe Continent do
  describe "to_s" do
    it "should return name" do
      @europe = FactoryGirl.build(:continent)
      @europe.to_s.should == 'Europe'
    end
  end
end
