require 'spec_helper'

describe BranchContactsController do
  before do
    Branch.delete_all
    BranchContact.delete_all
    @branch = FactoryGirl.create(:branch)
    @branch_contact = FactoryGirl.create(:branch_contact)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  describe "index" do
    it "should be success" do
      get :index, branch_id: @branch.id
      response.should be_success
    end
  end

  describe "new" do
    it "should be success" do
      get :new, branch_id: @branch.id
      response.should be_success
    end
  end
  
  describe "create" do
    it "should render failure if creating fails" do
      post :create, branch_id: @branch.id
      response.should render_template('new')
    end

    it "should success create" do
      BranchContact.delete_all
      expect {
        post :create, branch_id: @branch.id,  branch_contact: {
          name: 'Test Branches Contact2', phone: "09877773788", mobile:  "0939999999", fax: "0999399999999", email: "extra33ck@example.com", branch_id: @branch.id
        }
      }.to change { BranchContact.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      put :update, branch_id: @branch.id, id: @branch_contact.id, branch_contact: {name: ''}
      response.should render_template('edit')
    end

    it "should update Branch" do
      put :update, branch_id: @branch.id, id: @branch_contact.id, branch_contact: {name: 'test2'}
      @branch_contact.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to Branch" do
      delete :destroy, branch_id: @branch.id, id: @branch_contact.id
      response.should redirect_to(branch_branch_contacts_path(@branch))
    end
  end
  
end
