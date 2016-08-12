require 'spec_helper'

describe ModellsController do
  before do
    @admin = FactoryGirl.create(:admin)
    @category = FactoryGirl.create(:category)
    @brand = FactoryGirl.create(:brand)
    sign_in @admin
  end
  
  describe "index" do
    it "should be success" do
      get :index, brand_id: @brand
      response.should be_success
    end
  end

  describe "new" do
    it "should be success" do
      get :new, brand_id: @brand
      response.should be_success
    end
  end

  describe "create" do
    it "should render failure if creating fails" do
      post :create, brand_id: @brand
      response.should render_template('new')
    end

    it "should success create" do
      Modell.delete_all()
      expect {
        post :create, brand_id: @brand, modell: {name: 'model', brand_id: @brand.id, category_id: @category.id}
      }.to change { Modell.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      Modell.delete_all()
      @modell = FactoryGirl.create(:modell)
      put :update, brand_id: @brand, id: @modell.id, modell: {name: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      Modell.delete_all()
      @modell = FactoryGirl.create(:modell)
      put :update, brand_id: @brand,  id: @modell.id, modell: {name: 'TEST2'}
      @modell.reload.name.should == 'TEST2'
    end
  end

  describe "destroy" do
    it "should be redirect to index" do
      Modell.delete_all()
      @modell = FactoryGirl.create(:modell)
      delete :destroy,brand_id: @brand, id: @modell.id
      response.should redirect_to(brand_modells_path(@brand))
    end
  end


  
end
