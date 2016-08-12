require 'spec_helper'

describe Currency do
  describe "update rates" do
    before do
      FactoryGirl.build(:currency)
      FactoryGirl.build(:eur)
      stub_request(:get, "http://openexchangerates.org/latest.json").
        to_return(status: 200, body: Rails.root.join('spec/fixtures/exchange_rates.json').read)
    end

    it "should update exchange rates" do
      Currency.update_rates
      Currency.find_by_name('USD').reload.rate.to_f.should == 1
      Currency.find_by_name('EUR').reload.rate.to_f.should == 0.757754
    end

    it "should create currency if it's not created yet" do
      Currency.update_rates
      ltl = Currency.find_by_name('LTL')
      ltl.should_not be_nil
      ltl.rate.should == 2.6159
    end
  end

  describe "to hash" do
    FactoryGirl.build(:currency)
    FactoryGirl.build(:eur)

    it "should index currencies by name" do
      Currency.to_hash.should == {'USD' => 1, "LTL"=>2.6159, 'EUR' => 0.757754}
    end
  end
end
