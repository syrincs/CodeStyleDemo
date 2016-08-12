require 'spec_helper'

describe ContactsController do
  before do
     Contact.delete_all
     @admin = FactoryGirl.create(:admin)
     @user = FactoryGirl.create(:user)
     sign_in @admin
  end

  describe "index" do
    it "should be success" do
      get :index
      response.should be_success
    end

    it "should allow assign contacts of current user" do
      @contact = FactoryGirl.create(:contact)
      @fire_contact = FactoryGirl.create(:fire_contact, user: @user)
      get :index
      assigns[:contacts].should == [@contact]
    end

    it "should assign search" do
      @contact = FactoryGirl.create(:contact)
      @fire_contact = FactoryGirl.create(:fire_contact)
      get :index, contacts_search: {firstname: 'emerge'}
      assigns[:search].should be_instance_of(ContactsSearch)
      assigns[:search].firstname.should == 'emerge'
    end

    it "should allow searching records" do
      Contact.delete_all
      @contact = FactoryGirl.create(:contact)
      @fire_contact = FactoryGirl.create(:fire_contact)
      get :index, contacts_search: {firstname: 'emerge'}
      assigns[:contacts].should == [@contact]
    end

    it "should allow searching records by country" do
      @contact = FactoryGirl.create(:contact)
      @fire_contact = FactoryGirl.create(:fire_contact)
      @russia = FactoryGirl.create(:russia)
      get :index, contacts_search: {country_id: @russia.id}
      assigns[:contacts].should == [@fire_contact]
    end
  end

  describe "new" do
    it "should be success" do
      get :new
      response.should be_success
    end
  end

  describe "create" do
    it "should redirect to contacts_path" do
      post :create, contact: {email: 'contact@example.com'}
      response.should redirect_to(contacts_path)
    end

    it "should create contact" do
      expect {
        post :create, contact: {email: 'contact@example.com'}
      }.to change(@admin.contacts, :count).by(1)
    end

    it "should render failure if creating fails" do
      post :create
      response.should render_template('new')
    end
  end

  describe "edit" do
    before do
      @contact = FactoryGirl.create(:contact)
    end

    it "should be success" do
      get :edit, id: @contact.id
      response.should be_success
    end
  end

  describe "update" do
    before do
      @contact = FactoryGirl.create(:contact)
    end

    it "should be redirect to contacts" do
      put :update, id: @contact.id
      response.should redirect_to(contacts_path)
    end

    it "should update contact" do
      put :update, id: @contact.id, contact: {email: 'new_email@example.com'}
      @contact.reload.email.should == 'new_email@example.com'
    end

    it "should render failure if updating fails" do
      put :update, id: @contact.id, contact: {email: ''}
      response.should render_template('edit')
    end
  end

  describe "destroy" do
    before do
      @contact = FactoryGirl.create(:contact)
    end

    it "should be redirect to contacts" do
      delete :destroy, id: @contact.id
      response.should redirect_to(contacts_path)
    end

    it "should destroy contact" do
      delete :destroy, id: @contact.id
      Contact.exists?(@contact).should be_false
    end
  end

  describe "unsubscribe" do
    before do
      sign_out
      Contact.delete_all
      @contact = FactoryGirl.create(:contact)
    end

    it "should be success" do
      get :unsubscribe, autologin_secret: @contact.autologin_secret
      response.should be_success
    end

    it "should delete contact" do
      @fire_contact = FactoryGirl.create(:fire_contact)
      get :unsubscribe, autologin_secret: @contact.autologin_secret
      Contact.all.should == [@fire_contact]
    end

    it "should not delete contact if auth token is invalid" do
      get :unsubscribe, autologin_secret: (@contact.autologin_secret << "xxx")
      Contact.all.should == [@contact]
    end
  end
end