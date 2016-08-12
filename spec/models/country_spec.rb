require 'spec_helper'

describe Country do
  describe "to_s" do
    it "should return name" do
      @uk = FactoryGirl.build(:country)
      @uk.to_s.should == 'UK'
    end
  end
end
