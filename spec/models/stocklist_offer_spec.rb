require 'spec_helper'

describe StocklistOffer do
  describe "save" do
    def prepare
      Stocklist.delete_all
    end
    it "should set offer.stocklist" do
      prepare
      @offer = FactoryGirl.create(:offer)
      @stocklist = FactoryGirl.create(:stocklist)
      @stocklist_offer = StocklistOffer.new(@stocklist, @offer)
      @stocklist_offer.save.should be_true
      @offer.reload.stocklist.should == @stocklist
    end

    it "should return false if offer is nil" do
      @stocklist_offer = StocklistOffer.new(FactoryGirl.attributes_for(:stocklist), nil)
      @stocklist_offer.save.should be_false
      @stocklist_offer.should have(1).error_on(:id)
    end

    it "should return false if offer has stocklist" do
      @offer = FactoryGirl.create(:offer)
      @stocklist = FactoryGirl.create(:stocklist)
      @stocklist_offer = StocklistOffer.new(@stocklist, @offer)
      @offer = FactoryGirl.create(:offer, stocklist: @stocklist)
      @stocklist_offer.save.should be_false
      @stocklist_offer.should have(1).error_on(:id)
    end
  end

  describe "destroy" do
    before do
      @stocklist = FactoryGirl.create(:stocklist)
      @offer = FactoryGirl.create(:offer, stocklist: @stocklist)
    end
    

    it "should set offer.stocklist to nil" do
      @stocklist_offer = StocklistOffer.new(@stocklist, @offer)
      @stocklist_offer.destroy
      @offer.reload.stocklist.should be_nil
    end
  end

  describe "indentity" do
    before do
      @stocklist = FactoryGirl.create(:stocklist)
      @offer = FactoryGirl.create(:offer, stocklist: @stocklist)
    end
    
    it "should delegate to offer" do
      @stocklist_offer = StocklistOffer.new(@stocklist, @offer)
      @stocklist_offer.id.should == @offer.id
      @stocklist_offer.to_key.should == @offer.to_key
    end

    it "should return nil if there's no offer" do
      @stocklist_offer = StocklistOffer.new(@stocklist, nil)
      @stocklist_offer.id.should be_nil
      @stocklist_offer.to_key.should be_nil
    end
  end
end
