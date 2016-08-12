require 'spec_helper'

describe IndexController do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in @admin
  end

  describe "show" do
    it "should be success" do
      get :show, page: "ticker"
      response.should be_success
    end
  end
end
