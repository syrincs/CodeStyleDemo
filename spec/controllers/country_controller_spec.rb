require 'spec_helper'

describe CountriesController do
  before do
    Country.delete_all(['name <> ?', 'UK'])
    @admin = FactoryGirl.create(:admin)
    @country = FactoryGirl.create(:country, name: "JPN")
    sign_in @admin
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
        post :create, country: {name: "test"}
      }.to change { Country.count }.by(1)
    end
  end
  
  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @country.id, country: {name: ''}
      response.should render_template('edit')
    end
    
    it "should update Brand" do
      put :update, id: @country.id, country: {name: 'test2'}
      @country.reload.name.should == 'test2'
    end
  end

   describe "destroy" do
    it "should be redirect to modells" do
      @country = FactoryGirl.create(:country, name: "test2")
      delete :destroy, id: @country.id
      response.should redirect_to(countries_path)
    end
  end

  
end
