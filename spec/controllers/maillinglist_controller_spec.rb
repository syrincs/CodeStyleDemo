require 'spec_helper'

describe MailinglistsController do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end
  
  describe "index" do
    it "should be success" do
      get :index
      response.should be_success
    end
  end

  describe "new" do
    it "should be success" do
      get :new
      response.should be_success
    end
  end

  describe "create" do
    it "should render failure if creating fails" do
      post :create
      response.should render_template('new')
    end

    it "should success create" do
      Mailinglist.delete_all()
      expect {
        post :create, mailinglist: {name: "mytestmail", from: "mytestmail@roepa.com", reply_to: "mytestmailreply@roepa.com"}
      }.to change { Mailinglist.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      Mailinglist.delete_all()
      @mailing_list = FactoryGirl.create(:mailing_list)
      put :update, id: @mailing_list.id, mailinglist: {name: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      Mailinglist.delete_all()
      @mailing_list = FactoryGirl.create(:mailing_list)
      put :update, id: @mailing_list.id, mailinglist: {name: 'mytestmail2'}
      @mailing_list.reload.name.should == 'mytestmail2'
    end
  end

  describe "destroy" do
    it "should be redirect to Index" do
      Mailinglist.delete_all()
      @mailing_list = FactoryGirl.create(:mailing_list)
      delete :destroy, id: @mailing_list.id
      response.should redirect_to(mailinglists_path)
    end
  end
end
