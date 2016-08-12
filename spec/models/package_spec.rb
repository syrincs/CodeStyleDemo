require 'spec_helper'

describe Package do
  it_should_behave_like 'with price' do
    let :subject_with_price do
      FactoryGirl.create(:package)
    end

    let :subject_without_price do
      FactoryGirl.create(:package,price: 1)
    end
  end

  describe "to_s" do
    it "should return id" do
      @package = FactoryGirl.create(:package)
      @package.to_s.should == "package deal #{@package.id}"
    end
  end
end
