require 'spec_helper'

describe "notifications" do
  def prepair
    Message.delete_all
    Offer.delete_all
    Notification.delete_all
    User.delete_all(['email <> ?' ,"horst@roepa.com"])
    @offer = FactoryGirl.create(:offer)
    @message = FactoryGirl.create(:message)
    @user_message = FactoryGirl.create(:user_message)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
    visit root_path
  end

  def first_row
    all('tr')[2]
  end

  it "should allow viewing your notifications" do
    prepair
    click_link 'Notifications 1'
    page.should contain_table(
      ['', 'Date', 'Subject', 'Tools'],
      [''],
      ['', I18n.l(Notification.last.created_at), "Offer #{@offer.id}, a brand model from 1980", 'delete']
    )
  end

  it "should allow opening notification subject" do
    prepair
    click_link 'Notifications 1'
    click_link "Offer #{@offer.id}, a brand model"
    current_path.should == offer_path(:en, nil, @offer)
    find_link('Notifications').all('span.unread-count').should == []
  end

  it "should allow marking notifications as unread", js: true do
    sleep(5)
    prepair
    click_link 'Notifications 1'
    first_row[:class].should == 'unread'
    sleep(5)
    first_row.first('a.indicator').click
    first_row[:class].should == 'unread'
    sleep(5)
    first_row.first('a.indicator').click
    first_row[:class].should == ''
  end

  it "should allow filtering unread notifications", js: true do
    sleep(5)
    prepair
    Notification.update_all(viewed: true)
    click_link 'Notifications'

    click_link 'Unread'
    page.should contain_table(['', 'Date', 'Subject', 'Tools'], [''])

    click_link 'All'
    page.should contain_table(
      ['', 'Date', 'Subject', 'Tools'],
      [''],
      ['', I18n.l(Notification.last.created_at), "Offer #{@offer.id}, a brand model from 1980", 'delete']
    )
  end

  it "should allow deleting notifications", js: true do
    sleep(5)
    prepair
    click_link 'Notifications 1'
    click_link 'delete'
    page.evaluate_script('window.confirm = function() { return true; }')
    click_link 'Notifications'
    page.should contain_table(['', 'Date', 'Subject', 'Tools'], [''])
  end
end