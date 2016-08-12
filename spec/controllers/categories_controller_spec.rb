require 'spec_helper'

describe CategoriesController do
  before do
      @admin = FactoryGirl.create(:admin)
      sign_in @admin
  end
  
  describe "show" do
    before do
      @printing = FactoryGirl.create(:category)
    end

    it "should be success" do
      get :show, id: @printing.id
      response.should be_success
    end

    describe "with subcategories" do
      it "should assign subcategories" do
        Category.delete_all(['name = ?','Stationary presses'])
        @cylinder = FactoryGirl.create(:cylinder)
        @pre_press = FactoryGirl.create(:pre_press)
        get :show, id: @printing.id
        assigns[:subcategories].should == [@cylinder]
      end

      it "should order subcategories by position" do
        @cylinder = FactoryGirl.create(:cylinder, position: 1)
        @stationary_presses = FactoryGirl.create(:stationary_presses, position: 2)
        get :show, id: @printing.id
        assigns[:subcategories].should == [@cylinder, @stationary_presses]
      end
    end

    describe "with offers" do
      before do
        Offer.delete_all
      end
      it "should render assign offers that belong to category" do
        @offer = FactoryGirl.create(:offer)
        @offer2 = FactoryGirl.create(:offer2)
        get :show, id: @printing.id
        assigns[:offers].should == [@offer]
      end

      it "should skip not approved offers" do
        @offer = FactoryGirl.create(:offer, approved: false)
        get :show, id: @printing.id
        assigns[:offers].should == []
      end

      it "should order offers by field" do
        @offer = FactoryGirl.create(:offer, approved: true)
        @tom_offer = FactoryGirl.create(:tom_offer)
        get :show, id: @printing.id, order: 'id:asc'
        assigns[:offers].should == [@offer, @tom_offer]
      end

      it "should paginate offers" do
        get :show, id: @printing.id, page: 3
        assigns[:offers].current_page.should == 3
      end
    end
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
        post :create, category: {name: "test"}
      }.to change { Category.count }.by(1)
    end
  end

  describe "update" do
    it "should render failure if updating fails" do
      @category = FactoryGirl.create(:category, name: "test")
      put :update, id: @category.id, category: {name: ''}
      response.should render_template('edit')
    end

    it "should updating success" do
      @category = FactoryGirl.create(:category, name: "test")
      put :update, id: @category.id, category: {name: 'test2'}
      @category.reload.name.should == 'test2'
    end
  end

  describe "destroy" do
    it "should be redirect to Categories" do
      @category = FactoryGirl.create(:category, name: "test2")
      delete :destroy, id: @category.id
      response.should redirect_to(categories_path)
    end
  end


end