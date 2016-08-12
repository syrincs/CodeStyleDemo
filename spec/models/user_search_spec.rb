require 'spec_helper'

describe UserSearch do
  describe "search" do
    before do
      User.delete_all(['email <> ?' ,"horst@roepa.com"])
      @europe = FactoryGirl.create(:continent)
      @russia = FactoryGirl.create(:russia)
      @uk = FactoryGirl.create(:country)
      @europe.countries.delete
      @europe.countries << @uk
      @user = FactoryGirl.create(:user, city: 'moscow', country: @russia)
      @horst = FactoryGirl.create(:horst)
    end

    it "should allow searching by id" do
      UserSearch.new(id: @user.id).users.should == [@user]
    end

    it "should allow searching by company" do
      UserSearch.new(company: 'charles ind').users.should == [@user]
    end

    it "should allow searching by first name" do
      UserSearch.new(firstname: 'charles').users.should == [@user]
    end

    it "should allow searching by last name" do
      UserSearch.new(lastname: 'charls').users.should == [@user]
    end

    it "should allow searching by email" do
      UserSearch.new(email: 'user').users.should == [@user]
    end

    it "should allow searching by street" do
      UserSearch.new(street: 'sesame st. 7').users.should == [@user]
    end

    it "should allow searching by city" do
      UserSearch.new(city: 'london').users.should == [@horst]
    end

    it "should allow searching by country" do
      UserSearch.new(location_id: @uk.id, location_type: 'Country').users.should == [@horst]
    end

    it "should allow searching by continent" do
      UserSearch.new(location_id: @europe.id, location_type: 'Continent').users.should == [@horst]
    end

    it "should allow searching by role" do
      UserSearch.new(role: 'user').users.should == [@user, @horst]
    end
  end
end