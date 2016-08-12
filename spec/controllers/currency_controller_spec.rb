require 'spec_helper'

describe CurrenciesController do
  before do
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
      Currency.delete_all()
      expect {
        post :create, currency: {name: "TEST", rate: 2}
      }.to change { Currency.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      Currency.delete_all()
      @currency = FactoryGirl.create(:currency)
      put :update, id: @currency.id, currency: {name: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      Currency.delete_all()
      @currency = FactoryGirl.create(:currency)
      put :update, id: @currency.id, currency: {name: 'TEST2', rate: 2}
      @currency.reload.name.should == 'TEST2'
    end
  end

  describe "destroy" do
    it "should be redirect to index" do
      Currency.delete_all()
      @currency = FactoryGirl.create(:currency)
      delete :destroy, id: @currency.id
      response.should redirect_to(currencies_path)
    end
  end


  
end
