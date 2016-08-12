require 'spec_helper'

describe InquiriesController do
  describe "new" do
    before do
      @admin = FactoryGirl.create(:admin)
      @user = FactoryGirl.create(:user)
      sign_in @admin
      @offer = FactoryGirl.create(:offer)
    end
    

    it "should be success" do
      get :new, inquiry: {buyable_id: @offer.id, buyable_type: 'Offer'}
      response.should be_success
    end

    it "should set message body for inquiry" do
      controller.should_receive(:render_to_string).with("message", layout: "email").and_return('inquiry message')
      get :new, inquiry: {buyable_id: @offer.id, buyable_type: 'Offer'}
      assigns[:inquiry].message.should == 'inquiry message'
    end

    it "should not set message body for simple user" do
      sign_in @user
      get :new, inquiry: {buyable_id: @offer.id, buyable_type: 'Offer'}
      assigns[:inquiry].message.should be_nil
    end
  end
end
