require 'spec_helper'

describe OffersController do
  before do
    @admin = FactoryGirl.create(:admin)
    @user = FactoryGirl.create(:user)
    sign_in @admin
  end

  describe "destroy" do
    def prepare
      Offer.delete_all
      Message.delete_all
      @admin = FactoryGirl.create(:admin)
      @user = FactoryGirl.create(:user)
      @offer = FactoryGirl.create(:offer)
    end

    it "should redirect to user offers path" do
      prepare
      delete :destroy, id: @offer.id
      response.should redirect_to(offers_user_path(@user))
    end

    it "should redirect to custom path if asked" do
      prepare
      delete :destroy, id: @offer.id, return_to: 'outdated_offers'
      response.should redirect_to(outdated_offers_path)
    end

    it "should destroy offer" do
      prepare
      delete :destroy, id: @offer.id
      @offer.reload.deleted_at.should_not be_nil
    end
  end

  describe "bulk approve" do
    it "should redirect to to unapproved offers list" do
      post :bulk_approve
      response.should redirect_to(unapproved_offers_path)
    end

    it "should approve selected offers by current user" do
      @offer = FactoryGirl.create(:offer,approved: false)
      @offer2 = FactoryGirl.create(:offer2,approved: false)
      post :bulk_approve, list: [@offer.id]

      @offer.reload.should be_approved
      @offer2.reload.should_not be_approved
      @offer.messages.last.sender.should == @admin
    end
  end

  describe "update" do
    before do
      @offer = FactoryGirl.create(:offer,approved: false)
      @user = FactoryGirl.create(:user)
     sign_in @user
    end
    

    it "should redirect to user's offers path" do
      put :update, id: @offer.id
      response.should redirect_to(offers_user_path(@user))
    end

    it "should redirect back" do
      put :update, id: @offer.id, return_to: 'unapproved_offers'
      response.should redirect_to(unapproved_offers_path)
    end

    it "should redirect back to deleted offers" do
      put :update, id: @offer.id, return_to: 'deleted_offers'
      response.should redirect_to(deleted_offers_path)
    end

    it "should update offer" do
      put :update, id: @offer.id, offer: {description: 'new offer description'}
      @offer.reload.description.should == 'new offer description'
    end

    it "should confirm offer" do
      Timecop.freeze(2012, 4, 11)
      put :update, id: @offer.id
      @offer.reload.confirmed_at.should == Time.current
    end

    it "should unapprove offer if it's edited by a normal user" do
      pending
#       @offer.approve!(@admin)
#       put :update, id: @offer.id
#       @offer.reload.should_not be_approved
    end

    it "should render edit template if offer is invalid" do
      put :update, id: @offer.id, offer: {year: nil}
      response.should render_template('edit')
    end
  end

  describe "deleted" do
    it "should be success" do
      get :deleted
      response.should be_success
    end

    it "should assign deleted offers" do
      Offer.delete_all
      @offer = FactoryGirl.create(:offer,approved: true)
      @tom_offer = FactoryGirl.create(:tom_offer,deleted_at: Time.current)
      get :deleted
      assigns[:offers].should == [@tom_offer]
    end

    it "should paginate offers" do
      get :deleted, page: 2
      assigns[:offers].current_page.should == 2
    end
  end

  describe "remove" do
    before do
      @offer = FactoryGirl.create(:offer)
    end

    it "should redirect to user's offers" do
      delete :remove, id: @offer.id
      response.should redirect_to(offers_user_path(@user))
    end

    it "should redirect back" do
      delete :remove, id: @offer.id, return_to: 'deleted_offers'
      response.should redirect_to(deleted_offers_path)
    end

    it "should delete offer permanently" do
      delete :remove, id: @offer.id
      Offer.exists?(@offer).should be_false
    end
  end

  describe "bulk resurrect" do
    it "should redirect to deleted offers path" do
      post :bulk_resurrect
      response.should redirect_to(deleted_offers_path)
    end

    it "should resurrect selected offers" do
      @offer = FactoryGirl.create(:offer, deleted_at: Time.current)
      @offer2 = FactoryGirl.create(:offer2, deleted_at: Time.current)
      post :bulk_resurrect, list: [@offer.id]
      @offer.reload.deleted_at.should be_nil
      @offer2.reload.deleted_at.should_not be_nil
    end

    it "should remove selected offers if requested" do
      @offer = FactoryGirl.create(:offer)
      @offer2 = FactoryGirl.create(:offer2)
      post :bulk_resurrect, list: [@offer.id], remove: 'Remove'
      Offer.exists?(@offer).should be_false
      Offer.exists?(@offer2).should be_true
    end
  end
end
