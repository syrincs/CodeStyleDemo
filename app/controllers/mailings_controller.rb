# encoding: utf-8
class MailingsController < ApplicationController
  layout :determine_layout

  load_and_authorize_resource :mailing

  def index
    @mailings = @mailings
    @batch = 50
    @offset = params[:offset].to_i
    @filter = params[:filter].try(:strip)
    @mailings = @mailings.where("subject ILIKE ?", "%#{@filter}%") if @filter.present?
    @mailings = @mailings.offset(@offset)
    @more = [@mailings.count - @batch, 0].max
    @mailings = @mailings.limit(@batch).order("id DESC")
    render "index_more", :layout => false if params[:remote]
  end

  def new
    @mailing.reply_to = current_user.email
    @mailing.html = case
    when params[:offer_id]
      @offers = Offer.where(id: params[:offer_id].split(",").map(&:strip))
      render_to_string("new_detailed_offer_list", layout: "email", :formats => :html)
    when params[:stocklist_id]
      @stocklist = Stocklist.find(params[:stocklist_id])
      @mailing.subject = Time.current.strftime(_("Stocklist for %{date}") % {date: "%B %Y"})
      render_to_string("new_stocklist", layout: "email", :formats => :html)
    when params[:package_id]
      @package = Package.find(params[:package_id])
      render_to_string("new_package", layout: "email", :formats => :html)
    else
      render_to_string("new_minimal", layout: "email", :formats => :html)
    end
  end

  def create
    @mailing.sender = current_user
    if @mailing.save
      redirect_to :mailings, notice: _("Mailing created!")
    else
      render "new"
    end
  end

  def update
    if @mailing.update_attributes(params[:mailing])
      redirect_to :mailings, notice: _("Mailing updated!")
    else
      render "edit"
    end
  end

  def destroy
    @mailing.destroy
    redirect_to :mailings, notice: _("Mailing deleted!")
  end

  def html
    render :html => @mailing.html.html_safe
  end

  def copy
    @mailing = @mailing.dup
    render "new"
  end

  def recipients
    @recipients = @mailing.mailing_recipients
    @batch = 50
    @offset = params[:offset].to_i
    @filter = params[:filter].try(:strip)
    @recipients = @recipients.offset(@offset)
    @more = [@recipients.count - @batch, 0].max
    @recipients = @recipients.limit(@batch).order(:id)
    render "recipients_more", :layout => false if params[:remote]
  end

  protected

  def mailing_params
    attributes = [:subject, :reply_to, :html, :query_locations => [], :query_excluded_locations => []]
    params.require(:mailing).permit(attributes)
  end
end
