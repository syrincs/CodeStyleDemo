require 'spec_helper'

describe Offer do
  before do
    Offer.delete_all
  end
  it_should_behave_like 'with price' do
    let :subject_with_price do
      FactoryGirl.create(:offer)
    end

    let :subject_without_price do
      FactoryGirl.create(:offer, user_price: 1)
    end
  end

  describe "to_s" do
    it "should return id, brand and model" do
      @offer = FactoryGirl.create(:offer)
      @offer.to_s.should == "offer #{@offer.id}, a #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
    end
  end

  describe "approved" do
    it "should return offers" do
      @offer = FactoryGirl.create(:offer)
      Offer.approved.should == [@offer]
    end

    it "should not show unapproved offers" do
      @offer = FactoryGirl.create(:offer, approved: false)
      Offer.approved.should == []
    end

    it "should not show deleted offers" do
      @offer = FactoryGirl.create(:offer, deleted_at: Time.current)
      Offer.approved.should == []
    end

    it "should allow set timestamp when setting offer to approved" do
      Timecop.freeze
      subject.approved = true
      subject.approved_at.should == Time.current
    end

    it "should remove timestamp when setting offer to not approved" do
      subject.approved_at = Time.current
      subject.approved = false
      subject.approved_at.should be_nil
    end

    it "should allow setting using string values" do
      subject.approved_at = Time.current
      subject.approved = '0'
      subject.approved_at.should be_nil
    end

    it "should return false if offer is not approved" do
      subject.approved = false
      subject.approved.should be_false
      subject.approved?.should be_false
    end

    it "should return true if offer is not approved" do
      subject.approved = true
      subject.approved.should be_true
      subject.approved?.should be_true
    end
  end

  describe "permanently delete old" do
    it "should delete old offers" do
      @offer = FactoryGirl.create(:offer,deleted_at: 3.months.ago)
      Offer.permanently_delete_old
      Offer.all.should == []
    end

    it "should not delete offers that were deleted less than 3 months ago" do
      @offer = FactoryGirl.create(:offer,deleted_at: 11.weeks.ago)
      Offer.permanently_delete_old
      Offer.all.should == [@offer]
    end

    it "should not delete offers that were never destroyed" do
      @offer = FactoryGirl.create(:offer)
      Offer.permanently_delete_old
      Offer.all.should == [@offer]
    end

    it "should destroy all related records" do
      @inquiry = FactoryGirl.create(:inquiry)
      @offer = FactoryGirl.create(:offer, deleted_at: 3.months.ago)


      Offer.permanently_delete_old
      Inquiry.exists?(@inquiry).should be_false
    end
  end

  describe "mark deleted" do
    before do
      Offer.delete_all('id > 0')
      @offer = FactoryGirl.create(:offer)
      @user = FactoryGirl.create(:user)
    end
    

    it "should mark offer as deleted" do
      @offer.mark_deleted(@user)
      @offer.reload.deleted_at.should_not be_nil
    end

    it "should send email to user" do
      @admin = FactoryGirl.create(:admin)
      expect {
        @offer.mark_deleted(@admin)
      }.to change(ActionMailer::Base.deliveries, :size).by(1)

      last_email.from.should == ['admin@example.com']
      last_email.to.should == ['user@example.com']
      last_email.subject.should == "Offer #{@offer.id} - #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
    end

    it "should not send email if offer is destroyed by same user" do
      expect {
        @offer.mark_deleted(@user)
      }.not_to change(ActionMailer::Base.deliveries, :size)
    end

    it "should send email to users of inquiries" do

      @inquiry = FactoryGirl.create(:inquiry)
      @tom_inquiry = FactoryGirl.create(:tom_inquiry)
      expect {
        @offer.mark_deleted(@user)
      }.to change(ActionMailer::Base.deliveries, :size).by(2)

      last_email.from.should == ['mailings@roepa.com']
      last_email.to.should == ['tom@example.com']
      last_email.subject.should == "Inquiry #{@tom_inquiry.id} - Offer #{@offer.id}, a #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
    end
  end

  describe "for_confirmation" do
    it "should return offers that need to be confirmed again" do
      Timecop.travel(7.weeks.ago) {
        
        @offer = FactoryGirl.create(:offer )
      }
      Offer.for_confirmation.should == [@offer]
    end

    it "should not return recently updated offers" do
      Timecop.travel(5.weeks.ago) { 
        @offer = FactoryGirl.create(:offer )

      }
      Offer.for_confirmation.should == []
    end

    it "should not return deleted offers" do
      Timecop.travel(7.weeks.ago) {
        @offer = FactoryGirl.create(:offer, deleted_at: Time.current)
      }
      Offer.for_confirmation.should == []
    end
  end

  describe "ask updates" do
    before do
      Offer.delete_all
    end

    it "should send emails to all users with not updated offers" do
      Timecop.travel(7.weeks.ago) {
        @offer = FactoryGirl.create(:offer)
        @tom_offer  = FactoryGirl.create(:tom_offer)
      }
      expect {
        Offer.ask_updates
      }.to change(ActionMailer::Base.deliveries, :size).by(2)

      last_email.from.should == ['mailings@roepa.com']
      last_email.to.should == ['tom@example.com']
      last_email.subject.should == 'Please confirm the availability of your offers'
    end

    it "should only send 1 email per user" do
      Offer.delete_all
      Timecop.travel(7.weeks.ago) {
        @offer = FactoryGirl.create(:offer )
      }
      expect {
        Offer.ask_updates
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should not send emails for offers that were updated recently" do
      Timecop.travel(5.weeks.ago) { 
        @offer = FactoryGirl.create(:offer )
      }
      expect {
        Offer.ask_updates
      }.not_to change(ActionMailer::Base.deliveries, :size)
    end
  end

  describe "approve!" do
    before do
      @admin = FactoryGirl.create(:admin)
      @offer = FactoryGirl.create(:offer, approved: false)
    end

    it "should mark offer as approved" do
      @offer.approve!(@admin)
      @offer.reload.should be_approved
    end

    it "should send message from appraiser" do
      expect {
        @offer.approve!(@admin)
      }.to change { Message.count }.by(1)

      message = Message.last
      message.messageable.should == @offer
      message.sender.should == @admin
      message.text.should include('your offer has been listed in the EDB')
    end

    it "should not send message if offer was created by trusted user" do
      @horst = FactoryGirl.create(:horst)
      @offer = FactoryGirl.create(:offer,  creator: @horst)
      expect {
        @offer.approve!(@admin)
      }.not_to change { Message.count }
    end
  end

  describe "confirm" do
    before do
      Offer.delete_all
    end
    it "should set confirmed at on create" do
      Timecop.freeze(2012, 4, 6)
      @offer = FactoryGirl.create(:offer)
      @offer.confirmed_at.should == Time.current
    end

    it "should set confirmed at and save offer" do
      @offer = FactoryGirl.create(:offer)
      Timecop.freeze(2012, 4, 3)
      @offer.confirm!
      @offer.reload.confirmed_at.should == Time.current
    end
  end

  describe "similar" do
    before do
      Offer.delete_all
      @offer = FactoryGirl.create(:offer)
    end

    it "should return offers of same brand, model and similar year" do
      @tom_offer = FactoryGirl.create(:tom_offer, year: 1975)
      @modell = FactoryGirl.create(:modell)
      @offer2 = FactoryGirl.create(:offer2, year: 1985, modell: @modell)
      @offer.similar.should =~ [@tom_offer, @offer2]
    end

    it "should not return offers that are too old" do
      @tom_offer = FactoryGirl.create(:tom_offer, year: 1974)
      @offer.similar.should == []
    end

    it "should not return offers that are too new" do
      @tom_offer = FactoryGirl.create(:tom_offer, year: 1986)
      @offer.similar.should == []
    end

    it "should not return offers that have different model" do
      @modell2 = FactoryGirl.create(:modell2)
      @tom_offer = FactoryGirl.create(:tom_offer, year: 1980, modell: @modell2)
      @offer.similar.should == []
    end
  end

  describe "update category confirmed at" do
    before do
      Offer.delete_all
    end
    
    let :time do
      Time.utc(2012, 5, 4)
    end

    before do
      Timecop.freeze(time)
    end

    it "should update category confirmed at" do
      @offer = FactoryGirl.create(:offer)
      @printing = FactoryGirl.create(:category)
      @printing.reload.confirmed_at.should == time
    end

    it "should not update confirmed at if it didn't change" do
      @offer = FactoryGirl.create(:offer)
      Timecop.freeze(2012, 5, 8)
      @offer.update_attributes(user_price: 10)
      @printing = FactoryGirl.create(:category)
      @printing.reload.confirmed_at.should == time
    end

    it "should update confirmed at for category parents" do
      @offer2 = FactoryGirl.create(:offer2)
      @printing = FactoryGirl.create(:category)
      @printing.reload.confirmed_at.should == time
    end
  end
end