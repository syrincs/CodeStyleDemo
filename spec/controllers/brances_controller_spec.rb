require 'spec_helper'

describe BranchesController do
  before do
    Branch.delete_all
    BranchContact.delete_all
    @admin = FactoryGirl.create(:admin)
    @branch = FactoryGirl.create(:branch)
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
      Branch.delete_all
      expect {
        post :create, branch: { name: 'Test Branches', address: "Address Input", country_id: FactoryGirl.create(:country).id, description: "Text Input", location: "47.59247 7.58276", languages: "English", position: 1 }
      }.to change { Branch.count }.by(1)
    end
  end
  
  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @branch.id, branch: {name: ''}
      response.should render_template('edit')
    end
    
    it "should update Branch" do
      put :update, id: @branch.id, branch: {name: 'test2'}
      @branch.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to Branch" do
      delete :destroy, id: @branch.id
      response.should redirect_to(branches_path)
    end
  end
  
end
