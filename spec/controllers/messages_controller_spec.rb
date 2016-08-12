require 'spec_helper'

describe MessagesController do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end
  

  describe "new" do
    before do
      @offer = FactoryGirl.create(:offer)
    end

    it "should be success" do
      get :new, message: {messageable_id: @offer.id, messageable_type: 'Offer'}
      response.should be_success
    end

    it "should assign html body" do
      get :new, message: {messageable_id: @offer.id, messageable_type: 'Offer'}
      assigns[:message].template.should == 'offer_message'
    end

    it "should assign html body by messageable type" do
      Inquiry.delete_all
      @inquiry = FactoryGirl.create(:inquiry)
      get :new, message: {messageable_id: @inquiry.id, messageable_type: 'Inquiry'}
      assigns[:message].template.should == 'inquiry_message'
    end

    it "should assign minimized version of body in case user is not admin" do
      @user = FactoryGirl.create(:user)
      controller.sign_in @user
      get :new, message: {messageable_id: @offer.id, messageable_type: 'Offer'}
      assigns[:message].html_body.should be_nil
    end
  end
end
