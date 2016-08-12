require 'spec_helper'

describe IncotermsController do
  before do
    Incoterm.delete_all
    @admin = FactoryGirl.create(:admin)
    @incoterm = FactoryGirl.create(:incoterm)
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
      Incoterm.delete_all
      expect {
        post :create, incoterm: {name: "test"}
      }.to change { Incoterm.count }.by(1)
    end
  end
  
  describe "update" do
    it "should render failure if updating fails" do
      put :update, id: @incoterm.id, incoterm: {name: ''}
      response.should render_template('edit')
    end
    
    it "should update Incoterm" do
      put :update, id: @incoterm.id, incoterm: {name: 'test2'}
      @incoterm.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to Incoterm" do
      delete :destroy, id: @incoterm.id
      response.should redirect_to(incoterms_path)
    end
  end
  
end
