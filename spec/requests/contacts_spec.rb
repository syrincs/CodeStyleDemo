require 'spec_helper'

describe "contacts" do
  def prepare
    Contact.delete_all
  end

  it "should allow viewing contacts" do
    prepare
    @contact = FactoryGirl.create(:contact)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    click_link 'Address book'
    page.should contain_table(
      ["Company", "Name", "Email", "Phone", "Mobile", "City", "Country", "Tools"],
      ["", "Emergency Department", "emergency@example.com", "112", "", "london", "UK", "edit delete"]
    )
  end

  it "should allow searching contacts", js: true do
    prepare
    @contact = FactoryGirl.create(:contact)
    @fire_contact = FactoryGirl.create(:fire_contact)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    click_link 'Address book'
    click_link 'Search >>'

    within '#contacts-search' do
      fill_in 'Firstname', with: 'Emergency'
      click_button 'Search'
    end

    page.should contain_table(
      ["Company", "Name", "Email", "Phone", "Mobile", "City", "Country", "Tools"],
      ["", "Emergency Department", "emergency@example.com", "112", "", "london", "UK", "edit delete"]
    )
  end

  it "should allow adding contacts" do
    prepare
    @uk = FactoryGirl.create(:country)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    click_link 'Address book'
    click_link 'Add contact'

    fill_in 'Firstname', with: 'Fire'
    fill_in 'Lastname', with: 'Department'
    fill_in 'Email', with: 'fire@example.com'
    fill_in 'Phone', with: '113'
    fill_in 'City', with: 'london'
    select 'UK', from: 'Country'
    click_button 'Submit'

    page.should contain_table(
      ["Company", "Name", "Email", "Phone", "Mobile", "City", "Country", "Tools"],
      ["", "Fire Department", "fire@example.com", "113", "", "london", "UK", "edit delete"]
    )
  end

  it "should allow editing contacts" do
    prepare
    @contact = FactoryGirl.create(:contact)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    click_link 'Address book'
    click_link 'edit'

    fill_in 'Email', with: '112@example.com'
    click_button 'Submit'

    page.should contain_table(
      ["Company", "Name", "Email", "Phone", "Mobile", "City", "Country", "Tools"],
      ["", "Emergency Department", "112@example.com", "112", "", "london", "UK", "edit delete"]
    )
  end

  it "should allow deleting contacts" do
    prepare
    @contact = FactoryGirl.create(:contact)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    click_link 'Address book'
    click_link 'delete'

    page.should contain_table(
      ["Company", "Name", "Email", "Phone", "Mobile", "City", "Country", "Tools"]
    )
  end
end