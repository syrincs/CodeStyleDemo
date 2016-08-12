require 'spec_helper'

describe ContinentsController do
  before do
    Continent.delete_all
    @admin = FactoryGirl.create(:admin)
    @continent = FactoryGirl.create(:continent)
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
        post :create, continent: {name: "test"}
      }.to change { Continent.count }.by(1)
    end
  end
  
  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @continent.id, continent: {name: ''}
      response.should render_template('edit')
    end
    
    it "should updating success" do
      put :update, id: @continent.id, continent: {name: 'test2'}
      @continent.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to index" do
      delete :destroy, id: @continent.id
      response.should redirect_to(continents_path)
    end
  end
  
end
