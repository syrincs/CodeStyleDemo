require 'spec_helper'

describe "offers" do
  def visit_offer
    visit root_path
    click_link 'Printing'
    click_link 'show'
  end

  def prepare
    Offer.delete_all
    Image.delete_all
    @offer = FactoryGirl.create(:offer) 
  end

  context "show" do
    it "should allow viewing offer" do
      prepare
      visit_offer

      page.text.should include("Offer #{@offer.id}")
      page.text.should include("Price: USD 11.000 fca")
      page.should contain_table(
        ["Brand", "Model"], ["brand", "model"],
        ["Technical details"],
        ["Size", "100x80mm"],
        ["Additional information"],
        ["Age", "1980"], ["Condition", "good"],
        ["Condition of cylinders", "good"],
        ["Location", "UK"],
        ["Still in production", "Yes"],
        ["Test possible", "Yes"],
        ["Complete and in working condition", "Yes"],
        ["Available", "Immediately"],
        ["Offer last updated", I18n.l(@offer.updated_at)],
        ["Description"], ["Charles first offer"]
      )
    end

    it "should warn if offer is not approved" do
      prepare
      @offer = FactoryGirl.create(:offer, approved: false)
      visit offer_path(:en, nil, @offer)
      find('.warning').text.should include('This offer has not been approved by our staff yet!')
    end

    it "should display images", js: true do
      sleep(5)
      prepare
      @image = FactoryGirl.create(:image)
      @image2 = FactoryGirl.create(:image2)
      
      visit_offer

      find('img.preview')[:src].should =~ %r{/system/image/data/#{@image2.id}/normal}
      thumb1, thumb2 = all('.image img')
      thumb1[:src].should =~ %r{/system/image/data/#{@image2.id}/preview}
      thumb2[:src].should =~ %r{/system/image/data/#{@image.id}/preview}
    end

    it "should display videos" do
      prepare
      @video = FactoryGirl.create(:video)
      @video2 = FactoryGirl.create(:video2)
      visit_offer

      thumb1, thumb2 = all('.video img')
      thumb1[:src].should == "https://img.youtube.com/vi/QH2-TGUlwu4/0.jpg"
      thumb2[:src].should == "https://img.youtube.com/vi/QH2-TGUlwu4/0.jpg"
    end

    it "should allow opening currency converter", js: true do
      prepare
      @eur = FactoryGirl.create(:eur)

      visit_offer
      click_link 'Currency converter'

      within '#dialog' do
        text.should include('Original price: USD 11.000 fca')
        select 'EUR'
        text.should include('Converted price: 7.700 EUR')
      end
    end

    it "should not display currency converter link if offer has no price" do
      prepare
      @offer = FactoryGirl.create(:offer, user_price: 0)
      visit_offer
      page.text.should_not include('Currency converter')
    end

    it "should allow seeing print version" do
      prepare
      visit_offer
      click_link 'Print version'
      page.find('h1.important').text.should == "Offer #{@offer.id}"
    end

    it "should show the new message dialog when the url has the write anchor", js: true do
      prepare
      @user = FactoryGirl.create(:user)
      sign_in @user

      visit offer_path(:en, nil, @offer, :anchor => "write")
      page.should have_css(".ui-dialog-title", :text => "Write new message")
    end
  end

  context "edit" do
    it "should show the new message dialog when the url has the write anchor", js: true do
      sleep(5)
      prepare
      @user = FactoryGirl.create(:user)
      sign_in @user
      visit edit_offer_path(:en, nil, @offer, :anchor => "write")
      page.should have_css(".ui-dialog-title", :text => "Write new message")
    end
  end
end