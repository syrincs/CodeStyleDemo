# encoding: utf-8
class OffersController < ApplicationController
  layout :determine_layout
  
  before_filter :find_or_build_offer

  authorize_resource

  before_filter :build_seller_message, :only => [:seller_message1, :seller_message2]
  before_filter :build_staff_message, :only => [:staff_message1, :staff_message2]
  before_filter :build_staff_seller_message, :only => [:staff_seller_message1, :staff_seller_message2]
  before_filter :enforce_current_user, only: [:new, :create]
  
  def print
    render layout: "print"
  end

  def show
    if current_user
      current_user.message_receptions.where(:message_id => @offer.messages.pluck(:id)).each{ |message| message.read! }
    end
  end

  def edit
    @form = OfferForm.new(@offer)
  end

  def create
    @form = OfferForm.new(@offer, params[:offer])
    @form.offer.creator = current_user
    if @form.save
      redirect_to [:offers, @offer.user], notice: _("Offer created!")
    else
      @clear_errors = params[:clear_errors].present?
      render "new"
    end
  end

  def update
    @form = OfferForm.new(@offer, params[:offer])
    @form.offer.confirmed_at = Time.now
    if @form.save
      return_or_redirect [:offers, @offer.user], notice: _("Offer updated!")
    else
      render "edit"
    end
  end

  def bulk_approve
    Offer.where(id: params[:list]).each do |offer|
      offer.approve!(current_user)
    end
    return_or_redirect unapproved_offers_path, notice: _("Selected offers approved!")
  end

  def bulk_delete
    offers = (manager? || admin?) ? Offer : current_user.offers
    offers = offers.where(id: params[:list]).to_a
    offers.each{ |offer| offer.mark_deleted(current_user) }
    return_or_redirect outdated_offers_path, notice: _("Selected offers deleted!")
  end

  def bulk_destroy
    offers = (manager? || admin?) ? Offer : current_user.offers
    offers = offers.where(id: params[:list]).to_a
    offers.each{ |offer| offer.destroy }
    return_or_redirect outdated_offers_path, notice: _("Selected offers destroyed!")
  end

  def bulk_email
    offers = Offer.where(id: params[:list]).to_a
    GuestMailer.offers_email(params[:email].strip, offers).deliver
  end

  def bulk_resurrect
    remove = params[:remove].present?
    Offer.where(id: params[:list]).each do |offer|
      if remove
        offer.destroy
      else
        offer.resurrect(current_user)
      end
    end
    return_or_redirect deleted_offers_path, notice: remove ? _("Selected offers destroyed!") : _("Selected offers resurrected!")
  end

  def resurrect
    @offer.resurrect(current_user)
    return_or_redirect [:offers, @offer.user], notice: _("Offer resurrected!")
  end

  def destroy
    @offer.mark_deleted(current_user)
    return_or_redirect [:offers, @offer.user], notice: _("Offer deleted!")
  end

  def remove
    @offer.destroy
    return_or_redirect [:offers, @offer.user], notice: _("Offer destroyed!")
  end

  def inquiries
    @page = params[:page]
    @inquiries = @offer.inquiries
  end

  def unapproved
    @batch = 50
    @offset = params[:offset].to_i
    @trusted = params[:trusted]
    @offers = Offer.unapproved
    @offers = @offers.created_by_trusted_user if @trusted.present?
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch).order(:id)
    render "unapproved_more", :layout => false if params[:remote]
  end

  def special
    @batch = 50
    @offset = params[:offset].to_i
    @offers = Offer.special
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch).order(:id)
    render "special_more", :layout => false if params[:remote]
  end

  def outdated
    @batch = 50
    @offset = params[:offset].to_i
    @offers = Offer.outdated
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch).order(:confirmed_at)
    render "outdated_more", :layout => false if params[:remote]
  end

  def deleted
    @batch = 50
    @offset = params[:offset].to_i
    @offers = Offer.deleted
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch).order("deleted_at DESC")
    render "deleted_more", :layout => false if params[:remote]
  end

  def form_images
    render layout: false
  end

  def form_videos
    render layout: false
  end

  def currency_converter
    @object = @offer
  end

  def assigned
    @batch = 50
    @offset = params[:offset].to_i
    @filter = OfferFilter.new(params[:filter])
    @offers = @filter.list(Offer.where(user_id: current_user.id))
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch)
    render "assigned_more", :layout => false if params[:remote]
  end

  def seller_message1
  end

  def seller_message2
    if @message.submit
      flash.notice = _("Thank you for conacting us, we'll reply to you sonnest!")
      render "seller_message2"
    else
      render "seller_message1"
    end
  end

  def staff_message1
    @message.html = render_to_string "staff_message_template", :locals => {:message => @message}
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

  def staff_seller_message1
  end

  def staff_seller_message2
    if @message.submit
      flash.notice = _("The message has been saved!")
      render "staff_seller_message2"
    else
      render "staff_seller_message1"
    end
  end

  def stocklist
    @stocklist = Stocklist.find_by_name!("ROEPA")
    @categories = Category.where(:id => Offer.not_deleted.where(:id => @stocklist.offers).joins(:modell).select(:category_id)).sort_by(&:path)
  end

  protected

  def enforce_current_user
    return if manager? || admin?
    @offer.user = current_user
  end

  def find_or_build_offer
    if params[:id].present?
      @offer = Offer.find(params[:id])
    else
      @offer = Offer.new
      if params[:offer]
        @offer.user_id = params[:offer][:user_id]
      end
    end
  end

  def build_seller_message
    @message = OfferSellerMessage.new(params[:message])
    @message.offer = @offer
    @message.user = current_user
  end

  def build_staff_message
    @message = OfferStaffMessage.new(params[:message])
    @message.offer = @offer
    @message.user = current_user
  end

  def build_staff_seller_message
    @message = OfferStaffSellerMessage.new(params[:message])
    @message.offer = @offer
    @message.user = current_user
  end
end
