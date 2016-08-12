require 'spec_helper'

describe BrandsController do
  before do
    Brand.delete_all
    @admin = FactoryGirl.create(:admin)
    @brand = FactoryGirl.create(:brand)
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
      Brand.delete_all
      expect {
        post :create, brand: {name: "test"}
      }.to change { Brand.count }.by(1)
    end
  end
  
  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @brand.id, brand: {name: ''}
      response.should render_template('edit')
    end
    
    it "should update Brand" do
      put :update, id: @brand.id, brand: {name: 'test2'}
      @brand.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to Brand" do
      delete :destroy, id: @brand.id
      response.should redirect_to(brands_path)
    end
  end
  
end
