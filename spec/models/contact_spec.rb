require 'spec_helper'

describe Contact do
  describe "auth token" do
    it "should return auth token" do
      @contact = FactoryGirl.build(:contact)
      @contact.auth_token.should == "da136d79"
    end
  end

  describe "autologin_secret" do
    it "should return autologin_secret" do
      @contact = FactoryGirl.build(:contact)
      @contact.autologin_secret.should == "c-#{@contact.id}-da136d79"
    end
  end
end
