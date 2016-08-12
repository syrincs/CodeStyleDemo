require 'spec_helper'

describe "inquiries", js: true do

  describe "making inquiry" do
    def cleandb
      Offer.delete_all
      Inquiry.delete_all
      Message.delete_all
      Package.delete_all
    end
    
    def prepare
      cleandb
      @offer = FactoryGirl.create(:offer)
      @user = FactoryGirl.create(:user)
      @admin = FactoryGirl.create(:admin)
      @package = FactoryGirl.create(:package)
    end

    def start_inquiry
      visit offer_path(:en, nil, @offer)
      click_link 'Make inquiry'
    end

    def submit_inquiry(&block)
      within '#new_inquiry' do
        find_field('Item').value.should == "Offer #{@offer.id}, a #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
        fill_html_field 'Message', with: 'This is my inquiry'
        instance_eval(&block) if block
        click_button 'Submit'
      end
    end

    it "should allow inquiring offers after login" do
      prepare
      sign_in @user
      start_inquiry
      submit_inquiry
      find('#alert_dialog').text.should == "Thank you! We'll contact you soonest."
    end

    it "should allow inquiring packages after login" do
      prepare
      sign_in @user
      visit package_path(:en, nil, @package)
      click_link 'Make inquiry'
      within '#new_inquiry' do
        find_field('Item').value.should == "Package deal #{@package.id}"
        fill_html_field 'Message', with: 'This is my inquiry'
        click_button 'Submit'
      end
      find('#alert_dialog').text.should == "Thank you! We'll contact you soonest."
    end

    it "should not allow inquiring deleted offers" do
      prepare
      @offer.mark_deleted(@user)
      sign_in @user
      visit offer_path(:en, nil, @offer)
      page.text.should include("This offer has already been sold on")
    end

    it "should allow logging in before inquiring" do
      prepare
      start_inquiry

      within 'form.login' do
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: @user.password
        click_button 'Login'
      end

      submit_inquiry
      find('#alert_dialog').text.should == "Thank you! We'll contact you soonest."
    end

    it "should allow registering before inquiring" do
      User.delete_all(['email <> ?' ,"horst@roepa.com"])
      prepare
      start_inquiry

      within '#new_user' do
        fill_in 'Company', with: 'Some inc.'
        fill_in 'Firstname', with: 'Charles'
        fill_in 'Lastname', with: 'Charlston'
        fill_in 'Street', with: 'Sesame st. 5'
        fill_in 'City', with: 'London'
        select 'UK', from: 'Country'
        fill_in 'Email', with: 'charles@example.com'
        click_button 'Create account'
      end

      submit_inquiry
      find('#alert_dialog').text.should == "Thank you! We'll contact you soonest."
    end

    it "should allow inquiring as admin" do
      prepare
      sign_in @admin
      start_inquiry
      submit_inquiry do
        fill_in_autocomplete 'Buyer', 'charles'
      end
      find('#alert_dialog').text.should == "Thank you! We'll contact you soonest."
    end

    it "should allow viewing your inquiry" do
      prepare
      @inquiry = FactoryGirl.create(:inquiry)
      sign_in @user
      visit offer_path(:en, nil, @offer)
      text.should_not include('Make inquiry')
      click_link 'Inquiry pending'
      click_link 'click here'
      current_path.should == inquiry_path(:en, nil, Inquiry.last)
    end
  end


  describe "viewing inquiry" do
    def prepare_inquiry
      Offer.delete_all
      Inquiry.delete_all
      Message.delete_all
    end

    def open_inquiry(role = :user, options = {})
      prepare_inquiry
      @inquiry = FactoryGirl.create(:inquiry)
      @user = FactoryGirl.create(:user)
      @offer = FactoryGirl.create(:offer)
      sign_in @user
      visit offer_path(:en, nil, @offer, options)
      click_link 'Inquiry pending'
      click_link 'click here'
    end

    it "should allow viewing inquiry details", js: true  do
      sleep(5)
      open_inquiry
      find_field('Id').value.should == @inquiry.id.to_s
      find_field('Item').value.should == "Offer #{@offer.id}, a #{@offer.brand.name} #{@offer.modell.name} from #{@offer.year}"
      find_field('Created').value.should == I18n.l(@offer.created_at)
      find_field('Updated').value.should == I18n.l(@offer.updated_at)
    end

    it "should show messages history" do
      open_inquiry
      @inquiry_message = FactoryGirl.create(:inquiry_message)
      visit inquiry_path(:en, nil, @inquiry)
      within '.conversation-history' do
        text.should include('Conversation history')
        text.should include('Charles Charlston')
        text.should include(I18n.l(@inquiry.messages.last.created_at))
        text.should include('I am interested')
      end
    end

    it "should allow sending new message", js: true do
      open_inquiry
      @inquiry_message = FactoryGirl.create(:inquiry_message, html_body: 'My message')
      visit inquiry_path(:en, nil, @inquiry)
      page.text.should include("Charles Charlston")
      page.text.should include("My message")
    end

    it "should allow viewing offer" do
      open_inquiry
      click_link 'show item'
      current_path.should == offer_path(:en, nil, @offer)
    end

    it "should show the new message dialog when the url has the write anchor", js: true do
      open_inquiry
      visit inquiry_path(:en, nil, @inquiry)
      click_link 'Write new message'
      page.should have_css(".ui-dialog-title", :text => "Write new message")
    end
    
    it "should allow viewing buyer as admin/manager", js: true do
      sleep(5)
      prepare_inquiry
      @inquiry = FactoryGirl.create(:inquiry)
      @admin = FactoryGirl.create(:admin)
      sign_in @admin
      visit inquiry_path(:en, nil, @inquiry)
      click_link "show buyer"
      find_field('Company').value.should == "charles industries"
    end
    
  end
  
end