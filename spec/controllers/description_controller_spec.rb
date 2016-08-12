require 'spec_helper'

describe DescriptionsController do
  before do
    Description.delete_all
    @description = FactoryGirl.create(:description)
    @descriptiongroup = FactoryGirl.create(:descriptiongroup)
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  describe "index" do
    it "should be success" do
      get :index, descriptiongroup_id: @descriptiongroup.id
      response.should be_success
    end
  end

  describe "new" do
    it "should be success" do
      get :new, descriptiongroup_id: @descriptiongroup.id
      response.should be_success
    end
  end

  describe "create" do
    it "should render failure if creating fails" do
      post :create, descriptiongroup_id: @descriptiongroup.id
      response.should render_template('new')
    end

    it "should success create" do
      expect {
        post :create, descriptiongroup_id: @descriptiongroup.id, description: {abbr: "TEST", text: "TEXT", descriptiongroup_id: @descriptiongroup.id}
      }.to change { Description.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      put :update, descriptiongroup_id: @descriptiongroup.id, id: @description.id, description: {abbr: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      put :update, descriptiongroup_id: @descriptiongroup.id, id: @description.id, description: {abbr: 'TEST2'}
      @description.reload.abbr.should == 'TEST2'
    end
  end

  describe "destroy" do
    it "should be redirect to index" do
      delete :destroy, descriptiongroup_id: @descriptiongroup.id, id: @description.id
      response.should redirect_to(descriptiongroup_descriptions_path(@descriptiongroup))
    end
  end
  
end
