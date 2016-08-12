require 'spec_helper'

describe Notification do
  describe "not viewed" do
    before do
      Message.delete_all
      Notification.delete_all
    end
    it "should return notifications that are not viewed" do
      @message = FactoryGirl.create(:message)
      @user_message = FactoryGirl.create(:user_message)
      Notification.not_viewed.should have(1).element
    end

    it "should not return notifications that are viewed" do
      @message = FactoryGirl.create(:message)
      @user_message = FactoryGirl.create(:user_message)
      Notification.update_all(viewed: true)
      Notification.not_viewed.should have(0).elements
    end
  end
end
