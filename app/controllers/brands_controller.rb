# encoding: utf-8
class BrandsController < ApplicationController
  layout :determine_layout
  load_and_authorize_resource

  before_action :all_brands, only: [:index, :create, :update, :destroy]
  before_action :all_brand_modells, only: [:modells]

  def index
    session[:brands_page] = params[:brands_page].present? ?  params[:brands_page] : 1
    render partial: "index", locals: { brands: @brands }, layout: false if params[:remote]
  end

  def create
    respond_to do |format|
      if @brand.save
        flash.now[:success] = _("Brand created!")

        format.js
        format.html { redirect_to brands_path, success: _("Brand created!") }
      else
        format.js { render "new" }
        format.html { render "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        flash.now[:success] = _("Brand updated!")

        format.js
        format.html { redirect_to brands_path, success: _("Brand updated!") }
      else
        format.js { render "edit" }
        format.html { render "edit" }
      end
    end
  end

  def destroy
    respond_to do |format|
      @brand.destroy
      flash.now[:success] = _("Brand deleted!")

      format.js
      format.html { redirect_to brands_path, success: _("Brand deleted!") }
    end
  end

  def modells
    session[:brand_modells_page] = params[:brand_modells_page] if params[:brand_modells_page]
    render partial: "modells", locals: { brand_modells: @brand_modells }, layout: false if params[:remote]

    #respond_to do |format|
      # format.json do
      #   render json: [["", nil]].concat(@modells.for_select.map{ |v| [v.name, v.id] })
      # end
    #  format.html
    #end    
  end

  def overview
    @filter = params[:filter].try(:strip)
    @brands = Brand.with_offers
    @brands = @brands.where("name ILIKE ?", "%#{@filter}%") if @filter.present?
    @brands = @brands.order(:name)
    render "overview_list", layout: false if params[:remote]
    render layout: "screen2015"
  end

  protected

  def brand_params
    params.require(:brand).permit(:name)
  end

  def all_brands
    @filter = params[:filter].try(:strip)
    if @filter.present?
      @brands = @brands.where("name ILIKE ?", "%#{@filter}%")
    else
      @brands = Brand.all.order(:name).page(params[:brands_page].present? ? params[:brands_page] : session[:brands_page]).per_page(12)
    end
  end

  def all_brand_modells
    @brand_modells = @brand.modells

    @filter = params[:filter].try(:strip)
    if @filter.present?
      @brand_modells = @brand_modells.where("name ILIKE ?", "%#{@filter}%")
    else
      @brand_modells = @brand_modells.order(:name).page(params[:brand_modells_page]).per_page(12)
    end
  end
end
