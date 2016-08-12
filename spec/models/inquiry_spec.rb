require 'spec_helper'

describe Inquiry do
  before do
    Inquiry.delete_all
  end
  describe "to_s" do
    it "should return id and buyable" do
      @inquiry = FactoryGirl.create(:inquiry)
      @offer = FactoryGirl.create(:offer)
      @inquiry.to_s.should == "inquiry #{@inquiry.id} - offer #{@offer.id}, a #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
    end
  end

  describe "messages" do
    before do
      @user = FactoryGirl.create(:user)
    end

    it "should create message instance from message" do
      expect {
        @inquiry = FactoryGirl.create(:inquiry,message: '<html><body>inquiry</body></html>')
      }.to change { Message.count }.by(1)

      message = Message.last
      message.messageable.should == @inquiry
      message.text.should == 'inquiry'
      message.sender.should == @user
    end

    it "should send email if contact is admin" do
      @admin = FactoryGirl.create(:admin)
      expect {
        @inquiry = FactoryGirl.create(:inquiry,message: '<!DOCTYPE html><html><body>inquiry</body></html>',contact: @admin)    
      }.to send_email

      last_email.from.should == ['admin@example.com']
      last_email.html_part.body.should == "<!DOCTYPE html>\n<html><body>inquiry</body></html>\n"
    end
  end

  describe "contact updated" do
    before do
      @admin = FactoryGirl.create(:admin)
      @inquiry = FactoryGirl.create(:inquiry)
      @offer = FactoryGirl.create(:offer)
    end
    
    it "should create message" do
      expect {
        @inquiry.update_attributes(contact: @admin)
      }.to change { Message.count }.by(1)

      message = Message.last
      message.messageable.should == @inquiry
      message.sender.should == @admin
      message.text.should include("thank you for your interest in our Offer #{@offer.id}, a brand model")
    end
  end
end
