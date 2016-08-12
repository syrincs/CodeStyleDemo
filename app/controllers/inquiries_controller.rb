# encoding: utf-8
class InquiriesController < ApplicationController
  layout :determine_layout

  load_and_authorize_resource

  before_filter :build_buyer_message, only: [:buyer_message1, :buyer_message2]
  before_filter :build_staff_message, only: [:staff_message1, :staff_message2]
  before_filter :build_staff_buyer_message, only: [:staff_buyer_message1, :staff_buyer_message2]
  before_filter :build_closure, only: [:closure1, :closure2]

  def index
    @batch = 25
    @batch = params[:filter][:shown_items].to_i if params[:filter] && params[:filter][:shown_items].present?
    @filter = InquiryFilter.new(params[:filter])
    @inquiries = @filter.list.page(params[:inquiries_page]).per_page(@batch)
  end

  def assigned
    @batch = 50
    @offset = params[:offset].to_i
    @filter = InquiryFilter.new(params[:filter])
    @inquiries = @filter.list(Inquiry.where(assigned_employee_id: current_user.id))
    @inquiries = @inquiries.offset(@offset)
    @more = [@inquiries.count - @batch, 0].max
    @inquiries = @inquiries.limit(@batch)
    render "assigned_more", layout: false if params[:remote]
  end

  def unassigned
    @batch = 50
    @offset = params[:offset].to_i
    @inquiries = Inquiry.where(assigned_employee_id: nil).where("state <> 'closed'")
    @inquiries = @inquiries.offset(@offset)
    @more = [@inquiries.count - @batch, 0].max
    @inquiries = @inquiries.limit(@batch).order(:id)
    render "unassigned_more", layout: false if params[:remote]
  end

  def show
    if current_user
      current_user.message_receptions.where(message_id: @inquiry.messages.pluck(:id)).each{ |message| message.read! }
    end
  end

  def buyer_message1
  end

  def buyer_message2
    if @message.submit
      flash.notice = _("Thank you for contacting us, we'll reply to you sonnest!")
      render "buyer_message2"
    else
      render "buyer_message1"
    end
  end

  def staff_message1
    @message.html = render_to_string "staff_message_template"
    render :formats => :js
  end

  def staff_message2
    if @message.submit
      flash.notice = _("Message sent!")
      render "staff_message2"
    else
      render "staff_message1"
    end
  end

  def staff_buyer_message1
  end

  def staff_buyer_message2
    if @message.submit
      flash.notice = _("Message stored!")
      render "staff_buyer_message2"
    else
      render "staff_buyer_message1"
    end
  end

  def assign_contact1
  end

  def assign_contact2
    if @inquiry.update_attributes(params.require(:inquiry).permit(:assigned_employee_id))
      flash.notice = _("New sales contact assigned!")
      render "assign_contact2"
    else
      render "assign_contact1"
    end
  end

  def closure1
    @closure.html = render_to_string "closure_template"
    render :formats => :js
  end

  def closure2
    if @closure.submit
      flash.notice = _("Inquiry closed!")
      render "closure2"
    else
      render "closure1"
    end
  end

  protected

  def build_buyer_message
    @message = InquiryBuyerMessage.new(params[:message])
    @message.inquiry = @inquiry
    @message.user = current_user
  end

  def build_staff_message
    @message = InquiryStaffMessage.new(params[:message])
    @message.inquiry = @inquiry
    @message.user = current_user
  end

  def build_staff_buyer_message
    @message = InquiryStaffBuyerMessage.new(params[:message])
    @message.inquiry = @inquiry
    @message.user = current_user
  end

  def build_closure
    @closure = InquiryClosure.new(params[:closure])
    @closure.inquiry = @inquiry
    @closure.user = current_user
  end
end
