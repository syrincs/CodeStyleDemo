require 'spec_helper'

describe Search do
  describe "years" do
    it "should return years that offers exist for" do
      FactoryGirl.create(:offer, year: 2000)
      FactoryGirl.create(:offer2)
      subject.years.should == ["2000-#{Date.current.year}", "1980-1989", 2000, 1980]
    end

    it "should allow year ranges with customized labels" do
      FactoryGirl.create(:offer, year: 2002)
      subject.years.should == ["2001+", "2000-#{Date.current.year}", "1980-1989", 2002, 1980]
    end
  end

  describe "new offers" do
    before do
      Offer.delete_all
      @search = FactoryGirl.create(:search)
      @offer = FactoryGirl.create(:offer)
    end

    it "should return offers" do
      @offer = FactoryGirl.create(:offer, approved_at: Date.current + 3)
      @search.new_offers.should == [@offer]
    end

    it "should not return offers that were approved after search updated_at" do
      Offer.delete_all
      @offer = FactoryGirl.create(:offer, approved_at: 1.minute.ago)
      @search.new_offers.should == []
    end
  end

  describe "suggest new" do
    def prepare
      Search.delete_all
      @search = FactoryGirl.create(:search)
      Offer.delete_all
    end
    it "should suggest new offers for users" do
      prepare
      @offer = FactoryGirl.create(:offer)
      expect {
        Search.suggest_offers
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it "should not send email if no new offers exist" do
      prepare
      @offer = FactoryGirl.create(:offer,approved_at: 1.minute.ago)

      expect {
        Search.suggest_offers
      }.not_to change { ActionMailer::Base.deliveries.size }
    end

    it "should only send one email per user and include each offer only once" do
      prepare
      @user = FactoryGirl.create(:user)
      @modell2 = FactoryGirl.create(:modell2)
      @offer = FactoryGirl.create(:offer)
      @offer2 = FactoryGirl.create(:offer2)
      mail = double("mail", deliver: nil)
      UserMailer.should_receive(:suggest_offers).with(@user, [@offer, @offer2]).and_return(mail)
      Search.suggest_offers
    end

    it "should update search" do
      prepare
      @offer = FactoryGirl.create(:offer)
      Timecop.freeze(1.day.from_now)
      Search.suggest_offers
      @search.reload.updated_at.to_i.should == Time.current.to_i
    end
  end


  describe "Should can view by" do
    it "for_index" do
      @search = FactoryGirl.create(:search)
      @search2 = FactoryGirl.create(:search2)
      Search.for_index.should == [@search2, @search]
    end

    it "should have per_page function" do
      Search.per_page.should == 50
    end

  end
  
end