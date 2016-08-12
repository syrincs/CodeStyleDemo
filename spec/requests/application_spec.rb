require 'spec_helper'

describe "Application" do
  context "auto login" do
    before do
      @offer = FactoryGirl.create(:offer)
      visit root_path
    end

    it "accessing any link containing the autologin_secret should login the user" do
      page.should have_css('.login h3')
      visit offer_path(:en, @offer.autologin_secret, @offer)
      page.should_not have_css('.login h3')
    end

    it "accessing any link containing any invalid autologin_secret should not login the user" do
      page.should have_css('.login h3')
      visit offer_path(:en, @offer.autologin_secret[0..-6] + "fffff", @offer)
      page.should have_css('.login h3')
    end
  end
end
