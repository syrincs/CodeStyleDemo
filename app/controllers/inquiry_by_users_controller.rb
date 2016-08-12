# encoding: utf-8
class InquiryByUsersController < ApplicationController
  before_filter :build_inquiry_by_user
  before_filter :authenticate

  def show
    @template = "show"
    @template = "sold" if @inquiry_by_user.buyable.deleted?

    @pending_inquiry = Inquiry.find_by_buyable_and_user(@inquiry_by_user.buyable, current_user)
    @template = "pending" if @pending_inquiry
  end

  def create
    @inquiry_by_user.user = current_user
    if @inquiry_by_user.submit
      render "success"
    else
      render "error"
    end
  end

  protected

  def build_inquiry_by_user
    @inquiry_by_user = InquiryByUser.new(params[:inquiry_by_user])
  end
end
