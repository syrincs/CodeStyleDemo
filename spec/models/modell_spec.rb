require 'spec_helper'

describe Modell do
  describe "for index" do
    before do
      Modell.delete_all
    end
    it "should success order id asc" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)

      Modell.for_index.should == [@modell, @modell2]
    end
  end

  describe "with_offers" do
    before do
      Modell.delete_all
    end
    it "should success show with offer" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)

      Modell.with_offers.should == [@modell]
    end
  end

  describe "scope_for_search_select" do
    before do
      Modell.delete_all
    end
    it "should success show scope_for_search_select" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)
      @printing = FactoryGirl.create(:category)
      @brand = FactoryGirl.create(:brand)
      Modell.scope_for_search_select(@printing.id, @brand.id).should == [@modell]
    end
  end

  describe "for_search_select" do
    before do
      Modell.delete_all
    end
    it "should success show for_search_select" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)
      @printing = FactoryGirl.create(:category)
      @brand = FactoryGirl.create(:brand)
      
      Modell.formats_for_search_select(@printing.id, @brand.id, @modell.id).should == ["100x80mm"]
    end
  end

  describe "search by field" do
    before do
      sleep(5)
      Modell.delete_all
    end
    
    it "should success show with f_name" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      Modell.f_name("model").should == [@modell, @modell2]
    end

    it "should success show with f_brand_id" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @brand = FactoryGirl.create(:brand)
      Modell.f_brand_id(@brand.id).sort_by{|e| e[:id]}.should == [@modell, @modell2]
    end

    it "should success show with offers" do
      @modell = FactoryGirl.create(:modell)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)
      @modell.offers.should == [@offer]
      @modell2.offers.should == []
    end

    
  end


end
