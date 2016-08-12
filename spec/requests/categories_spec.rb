require 'spec_helper'
describe "categories" do
  before do
    
  end
  def prepare
    Category.delete_all
    Offer.delete_all
    Modell.delete_all
    @printing = FactoryGirl.create(:category)
  end

  it "should allow viewing subcategories" do
    prepare
    @offer2 = FactoryGirl.create(:offer2)
    @cylinder = FactoryGirl.create(:cylinder, position: 1)
    @stationary_presses = FactoryGirl.create(:stationary_presses, position: 2)
    
    visit root_path
    click_link 'Printing'
    page.should contain_table(
      ['Category', 'Last update', 'Offers'],
      ['Cylinder', I18n.l(@cylinder.confirmed_at), '1'],
      ['Stationary presses', '-', '0']
    )
  end

  it "should allow viewing offers of category" do
    prepare
    @offer = FactoryGirl.create(:offer)
    @tom_offer = FactoryGirl.create(:tom_offer)
    
    visit root_path
    click_link 'Printing'
    page.should contain_table(
      ["No", "Brand", "Model", "Size", "Location", "Age", "Price", "Tools"],
      [""],
      [@tom_offer.id.to_s, "brand", "model", "100x80mm", "UK", "1980", "USD 11.000 fca", "show"],
      ["Toms offer"],
      [@offer.id.to_s, "brand", "model", "100x80mm", "UK", "1980", "USD 11.000 fca", "show"],
      ["Charles first offer"]
    )
  end

  it "should display that no matching offers found if category contains no offers" do
    prepare
    visit root_path
    click_link 'Printing'
    page.should contain_table(
      ["No", "Brand", "Model", "Size", "Location", "Age", "Price", "Tools"],
      [""],
      ["No matching offers found."]
    )
  end

  it "should allow ordering offers" do
    prepare
    @offer = FactoryGirl.create(:offer)
    @tom_offer = FactoryGirl.create(:tom_offer)
    visit root_path
    click_link 'Printing'
    click_link 'No'

    find_link('No').should have_selector('.icon-order-asc')
    page.should contain_table(
      ["No", "Brand", "Model", "Size", "Location", "Age", "Price", "Tools"],
      [""],
      [@offer.id.to_s, "brand", "model", "100x80mm", "UK", "1980", "USD 11.000 fca", "show"],
      ["Charles first offer"],
      [@tom_offer.id.to_s, "brand", "model", "100x80mm", "UK", "1980", "USD 11.000 fca", "show"],
      ["Toms offer"],
    )
  end
end