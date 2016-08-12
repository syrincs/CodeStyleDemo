# encoding: utf-8
class IndexController < ApplicationController
  def show
    case secure_page
    when "ticker"
      render "ticker", layout: "minimal"
    else
      return send(secure_page) if action_methods.include?(secure_page)
      render secure_page
    end
  rescue ActionView::MissingTemplate => e
    raise AbstractController::ActionNotFound, _("Page '%{page}' does not exists.") % {page: secure_page}
  end

  def search1
    @batch = 50
    @offset = params[:offset].to_i
    @filter = OfferFilter.new(params[:filter], ["Max. paper size", "Colors"])
    @offers = @filter.list
    @offers = @offers.offset(@offset)
    @more = [@offers.count - @batch, 0].max
    @offers = @offers.limit(@batch)

    if params[:remote]
      render "search1_more", :layout => false
    else
      render "search1"
    end
  end

  def special_offers
    @offers = Offer.special.order(:id).page(params[:offers_page]).per_page(12)
    render :special_offers
  end

  protected

  def secure_page
    @secure_page ||= begin
      page = params[:page].gsub(/[^a-z_0-9]/i, "")
      page.present? ? page : "dummy"
    end
  end
end
