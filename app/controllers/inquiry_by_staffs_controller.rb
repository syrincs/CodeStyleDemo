# encoding: utf-8
class InquiryByStaffsController < ApplicationController
  before_filter :build_inquiry_by_staff

  def show
    @inquiry_by_staff.message = render_to_string("message")
    @inquiry_by_staff.assigned_employee_id = current_user.id
    render :formats => [:js]
  end

  def create
    @inquiry_by_staff.operator = current_user
    if @inquiry_by_staff.submit
      render "success"
    else
      render "error"
    end
  end

  protected

  def build_inquiry_by_staff
    @inquiry_by_staff = InquiryByStaff.new(params[:inquiry_by_staff])
  end
end
