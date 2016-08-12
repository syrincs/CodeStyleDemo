require 'spec_helper'

describe DescriptiongroupsController do
  before do
    Descriptiongroup.delete_all
    @descriptiongroup = FactoryGirl.create(:descriptiongroup)
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
      expect {
        post :create, descriptiongroup: {name: "TEST"}
      }.to change { Descriptiongroup.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @descriptiongroup.id, descriptiongroup: {name: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      put :update, id: @descriptiongroup.id, descriptiongroup: {name: 'TEST2'}
      @descriptiongroup.reload.name.should == 'TEST2'
    end
  end

  describe "destroy" do
    it "should be redirect to index" do
      delete :destroy, id: @descriptiongroup.id
      response.should redirect_to(descriptiongroups_path)
    end
  end
  
end
