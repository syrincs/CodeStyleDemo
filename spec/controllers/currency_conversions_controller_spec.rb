require 'spec_helper'

describe CurrencyConversionsController do
  describe "new" do
    it "should be success" do
      @offer = FactoryGirl.create(:offer)
      get :new, offer_id: @offer.id
      response.should be_success
    end

    it "should assign object by offer id" do
      @offer = FactoryGirl.create(:offer)
      get :new, offer_id: @offer.id
      assigns(:object).should == @offer
    end

    it "should assign object by package id" do
      @package= FactoryGirl.create(:package)
      get :new, package_id: @package.id
      assigns(:object).should == @package
    end
  end
end
