require 'spec_helper'

describe NotificationsController do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  let :notification do
    @message = FactoryGirl.create(:message)
    @user_message = FactoryGirl.create(:user_message)
    @admin.notifications.last
  end

  describe "index" do
    before do
      Message.delete_all
    end
    it "should be success" do
      get :index
      response.should be_success
    end

    it "should assign user's notifications order by date sent" do
      Inquiry.delete_all
      Message.delete_all
      @message = FactoryGirl.create(:message)
      @user_message = FactoryGirl.create(:user_message)
      @inquiry = FactoryGirl.create(:inquiry, contact: @admin)
      Timecop.travel(1.minute.from_now) { @inquiry_message = FactoryGirl.create(:inquiry_message) }
      get :index
      assigns[:notifications].collect(&:message).should == [@inquiry_message, @user_message]
    end

    it "should allow filtering not viewed notifications" do
      Message.delete_all
      Notification.delete_all
      @message = FactoryGirl.create(:message)
      @user_message = FactoryGirl.create(:user_message)
      #Notification.first.update_attribute(:viewed, true)

      get :index, filter: 'unread'
      assigns[:notifications].should have(1).element
    end

    it "should paginate notifications" do
      get :index, page: 2
      assigns[:notifications].current_page.should == 2
      assigns[:notifications].per_page.should == 50
    end
  end

  describe "show" do
    before do
      @offer = FactoryGirl.create(:offer)
    end

    it "should redirect to subject" do
      get :show, id: notification.id
      response.should redirect_to(offer_path(@offer))
    end

    it "should mark notification as viewed" do
      get :show, id: notification.id
      notification.reload.should be_viewed
    end
  end

  describe "toggle viewed" do
    it "should be success" do
      put :toggle_viewed, id: notification.id, format: 'json'
      response.should be_success
    end

    it "should update notification" do
      put :toggle_viewed, id: notification.id, format: 'json'
      notification.reload.should be_viewed
    end
  end

  describe "destroy" do
    it "should be success" do
      delete :destroy, id: notification.id, format: 'json'
      response.should be_success
    end

    it "should delete notification" do
      delete :destroy, id: notification.id, format: 'json'
      Notification.exists?(notification).should be_false
    end
  end
end
