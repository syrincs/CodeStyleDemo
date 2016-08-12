require 'spec_helper'

describe Message do
  before do
    Message.delete_all
  end
  describe "html body" do
    let :content do
      '<div class="icon"></div>the content'
    end

    let :html do
      %{<html><body><div>Not included</div><div class="content">#{content}</div></body></html>}
    end
    
    subject do      
      @message = FactoryGirl.create(:message, html_body: html)
    end

    it "should set html body" do
      subject.html_body.should == html
    end

    it "should extract text from html body" do
      subject.save!
      subject.text.should == content
    end

    it "should extract text from html even if it doesn't contain div.content" do
      subject.html_body = %{<html><body>#{content}</body></html>}
      subject.text.should == content
    end

    it "should assign html body after passing template" do
      subject = Message.new(messageable: build(:offer), sender: build(:admin), template: 'offer_deleted_by_admin')
      text = %{thank you for letting us know that this offer has already been sold/ is no longer available}

      subject.template.should == 'offer_deleted_by_admin'
      subject.html_body.should include(text)
      subject.text.should include(text)
    end
  end

  describe "email notification" do
    before do
      @admin = FactoryGirl.create(:admin)
      @offer = FactoryGirl.create(:offer)
    end
    

    it "should notify user" do
      expect {
        
       @message = FactoryGirl.create(:message)
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it "should not notify user if user is same as sender" do
      expect {
        @user = FactoryGirl.create(:user)
        @message = FactoryGirl.create(:message, sender: @user)
      }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  describe "interpolation" do
    before do
      @admin = FactoryGirl.create(:admin)
      @offer = FactoryGirl.create(:offer)
    end

    it "should interpolate in emails" do
      @message = FactoryGirl.create(:message, html_body: '<!DOCTYPE html><html><body><p>{firstname}, {subject_url}</p></body></html>')
      last_email.html_part.body.should == "<!DOCTYPE html>\n<html><body><p>Charles, http://test.localhost/en/#{@message.messageable.user.autologin_secret}/offers/#{@offer.id}</p></body></html>\n"
    end

    it "should interpolate in history" do
      @message = FactoryGirl.create(:message,html_body: '<!DOCTYPE html><html><body><p>{firstname}, {subject_url}</p></body></html>')
      @message.text.should == "<p>Charles, http://test.localhost/en/#{@message.messageable.user.autologin_secret}/offers/#{@offer.id}</p>"
    end
  end

  describe "confirmed at" do
    before do
      Message.delete_all
      @user = FactoryGirl.create(:user)
      @offer = FactoryGirl.create(:offer)
      @offer2 = FactoryGirl.create(:offer2)
      Timecop.freeze(2012, 4, 14)
    end

    it "should update confirmed_at if message is from owner of offer" do
      @user_message = FactoryGirl.create(:user_message)
      @offer.reload.confirmed_at.should == Time.current
    end

    it "should not update confirmed at if message if not from owner of offer" do
      @message = FactoryGirl.create(:message)
      @offer2.reload.confirmed_at.should_not == Time.current
    end
  end

  describe "notification" do
    let :notification do
      Notification.last
    end

    it "should send notification to contact if messageable has one" do
      @admin = FactoryGirl.create(:admin)
      @inquiry = FactoryGirl.create(:inquiry,contact: @admin)
      expect {
        @inquiry_message = FactoryGirl.create(:inquiry_message)
      }.to change { Notification.count }.by(1)

      notification.user.should == @admin
      notification.message.should == @inquiry_message
    end

    it "should not send notification to contact if message is send by him" do
      @admin = FactoryGirl.create(:admin)
      @inquiry = FactoryGirl.create(:inquiry, contact: @admin)
      expect {
        @admin_inquiry_message = FactoryGirl.create(:admin_inquiry_message)
      }.not_to change { Notification.count }
    end

    it "should send notification to all users that are involved in conversation" do
      @admin = FactoryGirl.create(:admin)
      @inquiry = FactoryGirl.create(:inquiry, contact: @admin)
      @admin_inquiry_message = FactoryGirl.create(:admin_inquiry_message)
      expect {
        @inquiry_message = FactoryGirl.create(:inquiry_message)
      }.to change { Notification.count }.by(1)

      notification.user.should == @admin
      notification.message.should == @inquiry_message
    end

    it "should only send 1 notification per user" do
      @message = FactoryGirl.create(:message)
      expect {
        @user_message = FactoryGirl.create(:user_message)
      }.to change { Notification.count }.by(1)
    end
  end
end