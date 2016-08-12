require 'spec_helper'

describe ApplicationController do
  describe "order" do
    it "should return default order" do
      controller.order.should == 'id:desc'
    end

    it "should return default order that is passed" do
      controller.order('id:desc').should == 'id:desc'
    end

    it "should return params[:order] if it's set" do
      controller.params[:order] = 'id:asc'
      controller.order('id:desc').should == 'id:asc'
    end

    it "should cache order" do
      controller.order('id:asc')
      controller.params[:order].should == 'id:asc'
      controller.order.should == 'id:asc'
    end
  end
end
