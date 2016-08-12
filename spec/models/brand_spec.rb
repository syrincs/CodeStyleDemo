require 'spec_helper'

describe Brand do
  describe "for index" do
    it "should success show for index" do
      Brand.delete_all
      @brand = FactoryGirl.create(:brand)
      Brand.for_index(1).should == [@brand]
    end
  end

  describe "for_select" do
    it "should success show for_select" do
      @brand = FactoryGirl.create(:brand)
      Brand.for_select.should == [@brand]
    end
  end

  describe "for_search_select" do
    it "should success show for_select" do
      @brand = FactoryGirl.create(:brand)
      @printing = FactoryGirl.create(:category)
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)
      Brand.for_search_select(@printing.id).should == [[@brand.name, @brand.id]]
    end
  end

  describe "should can get data from" do
    it "f_name" do
      @brand = FactoryGirl.create(:brand)
      Brand.f_name('b').should == [@brand]
    end

    it "offers" do
      Offer.delete_all
      @brand = FactoryGirl.create(:brand)
      @offer = FactoryGirl.create(:offer)
      Brand.offers.should == [@offer]
    end

    it "per_page" do
      Brand.per_page.should == 100
    end
  end
end
