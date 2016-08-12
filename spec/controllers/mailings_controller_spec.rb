require 'spec_helper'

describe MailingsController do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end
  

  describe "index" do
    it "should be success" do
      get :index
      response.should be_success
    end

    it "should order mailings" do
      Mailing.delete_all
      @contact = FactoryGirl.create(:admin)
      @mailing = FactoryGirl.create(:mailing)
      @contacts_mailing = FactoryGirl.create(:contacts_mailing)
      get :index
      assigns[:mailings].should == [@contacts_mailing, @mailing]
    end

    it "should paginate mailings" do
      get :index, page: 2
      assigns[:mailings].current_page.should == 2
    end
  end

  describe "create" do
    before do
      Mailing.delete_all
      @mailing_list = FactoryGirl.create(:mailing_list)
    end

    it "should redirect to mailings path" do
      post :create, mailing: {target_code: @mailing_list.id, subject: 'Hello'}
      response.should redirect_to(mailings_path)
    end

    it "should create mailing" do
      expect {
        post :create, mailing: {target_code: @mailing_list.id, subject: 'Hello'}
      }.to change { Mailing.count }.by(1)
    end

    it "should set sender" do
      post :create, mailing: {target_code: @mailing_list.id, subject: 'Hello'}
      assigns[:mailing].sender.should == @admin
    end

    it "should render new if validations fail" do
      post :create, mailing: {}
      response.should render_template('new')
    end
  end

  describe "update" do
    before do
      @mailing = FactoryGirl.create(:mailing)
    end
    

    it "should redirect to mailings path" do
      put :update, id: @mailing.id
      response.should redirect_to(mailings_path)
    end

    it "should update mailing" do
      put :update, id: @mailing.id, mailing: {subject: 'new subject'}
      @mailing.reload.subject.should == 'new subject'
    end

    it "should render edit if validations fail" do
      put :update, id: @mailing.id, mailing: {subject: ''}
      response.should render_template('edit')
    end
  end

  describe "destroy" do
    before do
      @mailing = FactoryGirl.create(:mailing)
    end

    it "should redirect to mailings path" do
      delete :destroy, id: @mailing.id
      response.should redirect_to(mailings_path)
    end

    it "should destroy mailing" do
      delete :destroy, id: @mailing.id
      Mailing.exists?(@mailing).should be_false
    end
  end
end
