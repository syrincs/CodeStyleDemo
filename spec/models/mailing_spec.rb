require 'spec_helper'

describe Mailing do
  describe "target" do
    before do
      @admin = FactoryGirl.create(:admin)
    end
    

    it "should return user's contacts if target code is 0" do
      @contact = FactoryGirl.create(:contact)
      @admin.mailings.build(target_code: '0').target.should == [@contact]
    end

    it "should return nil if target code is blank" do
      @admin.mailings.build(target_code: '').target.should be_nil
    end

    it "should return mailing list otherwise" do
      @mailing_list = FactoryGirl.create(:mailing_list)
      @admin.mailings.build(target_code: @mailing_list.id).target.should == @mailing_list
    end
  end

  describe "deliver" do
    describe "to mailing list" do
      before do
        Mailing.delete_all
        Mailinglist.delete_all
        User.delete_all(['email <> ?' ,"horst@roepa.com"])
        @mailing = FactoryGirl.create(:mailing)
        @user = FactoryGirl.create(:user)
        @tom = FactoryGirl.create(:tom)
        @mailing_list = FactoryGirl.create(:mailing_list)
        @user_in_mailing_list = @mailing_list.users << @user
        @tom_in_mailing_list = @mailing_list.users << @tom
      end

      it "should deliver emails" do
        expect {
          @mailing.deliver
        }.to send_email(2)

        last_email.from.should == ['mailings@roepa.com']
        last_email.reply_to.should == ['reply@roepa.com']
        last_email.to.should == ['tom@example.com']
        last_email.subject.should == 'Mailing subject'
        last_email.text_part.body.should == 'Hello'
        last_email.html_part.body.should == "<!DOCTYPE html>\n<html><body><p>Hello</p></body></html>\n"
      end

      it "should set delivery start and finish time" do
        Timecop.freeze(2012, 4, 18)
        @mailing.deliver
        @mailing.delivery_started_at.should == Time.current
        @mailing.delivery_finished_at.should == Time.current
      end

      it "should set deliveries and recipients count" do
        @mailing.deliver
        @mailing.recipients_count.should == 2
        @mailing.deliveries_count.should == 2
      end

      it "should interpolate body and subject" do
        @mailing.subject = @mailing.text_body = '{firstname}'
        @mailing.html_body = '<!DOCTYPE html><html><body><p>{firstname}</p></body></html>'
        @mailing.deliver

        last_email.subject.should == 'Tom'
        last_email.text_part.body.should == 'Tom'
        last_email.html_part.body.should == "<!DOCTYPE html>\n<html><body><p>Tom</p></body></html>\n"
      end
    end

    it "should allow mailing to address book" do
      Mailing.delete_all
      MailingRecipient.delete_all

      @contact = FactoryGirl.create(:contact)
      @contacts_mailing = FactoryGirl.create(:contacts_mailing)
      expect {
        @contacts_mailing.deliver
      }.to send_email(1)

      last_email.from.should == ['admin@example.com']
      last_email.reply_to.should == ['admin@example.com']
      last_email.to.should == ['emergency@example.com']
    end
  end
end
