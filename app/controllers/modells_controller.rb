# encoding: utf-8
class ModellsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource :modell

  before_action :all_modells, only: [:index, :destroy]
  before_filter :build_serials, only: [:new, :edit]

  def index
    session[:modells_page] = params[:modells_page].present? ?  params[:modells_page] : 1
    render partial: "index", locals: { modells: @modells }, layout: false if params[:remote]
  end

  def create
    respond_to do |format|
      if @modell.save
        flash.now[:success] = "Model created!"

        if URI(request.referrer).path == modells_path
          all_modells

          format.js
          format.html { redirect_to modells_path, success: "Model created!" }
        else  
          all_brand_modells

          format.js { render file: "brands/modells_create.js.coffee" }
          format.html { redirect_to brands_path, success: "Model created!" }
        end
      else
        format.js { render "new" }
        format.html { render "new" }
      end
    end
  end

  def update
    respond_to do |format|
      @modell.transaction do
        if @modell.update_attributes(params[:modell])
          if params[:modell_properties]
            @modell.property_values.destroy_all
            @modell.property_designations.where(kind: "Modell").destroy_all
            (params[:modell_properties] || []).each_with_index do |v, i|
              name = v[:name]
              if name.present?
                property = Property.find_by(name: name)
                property ||= Property.create!(name: name, type: "StringProperty")
                @modell.property_designations.create!(property: property, kind: "Modell")
                value = v[:value]
                if value.present?
                  @modell.property_values.create!(property: property, value: value)
                end
              end
            end
          end

          if params[:offer_properties]
            @modell.property_designations.where(kind: "Offer").destroy_all
            params[:offer_properties].split("|").each_with_index do |name|
              if name.present?
                property = Property.find_by(name: name)
                property ||= Property.create!(name: name, type: "StringProperty")
                @modell.property_designations.create!(property: property, kind: "Offer")
              end
            end
          end

          flash.now[:success] = "Model updated!"

          if URI(request.referrer).path == modells_path
            all_modells
            format.js
            format.html { redirect_to modells_path, success: "Model updated!" }
          else
            all_brand_modells
            format.js { render "update_brand_modell" }
            format.html { redirect_to brands_path, success: "Model updated!" }
          end
        else
          format.js { render "edit" }
          format.html { render "edit" }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      @modell.destroy
      flash.now[:success] = _("Modell deleted!")

      format.js
      format.html { redirect_to modells_path, success: _("Modell deleted!") }
    end
  end

  def remove_brand_modell
    respond_to do |format|
      @modell.destroy!
      flash.now[:success] = _("Modell deleted!")
      all_brand_modells

      format.js
      format.html { redirect_to [:modells, @modell.brand], success: _("Modell deleted!") }
    end
  end

  def overview
    @filter = params[:filter].try(:strip)
    @modells = Modell.with_offers
    @modells = @modells.where("name ILIKE ?", "%#{@filter}%") if @filter.present?
    @modells = @modells.order("LOWER(name)")
    render "overview_list", layout: false if params[:remote]
  end

  def clone
    @modell = @modell.clone!

    if params[:brand_id].present?
      redirect_to modells_brand_path(params[:brand_id]), notice: _("Modell cloned!")
    else
      redirect_to modells_path
    end
  end

  protected

  def build_serials
    3.times{ @modell.serials.build }
  end

  def modell_params
    params.require(:modell).permit(:name, :brand_id, :category_id, :modell_group_id)
  end

  def all_modells
    @filter = params[:filter].try(:strip)
    if @filter.present?
      @modells = @modells.where("name ILIKE ?", "%#{@filter}%")
    else
      @modells = Modell.all.order(:name).page(params[:modells_page].present? ? params[:modells_page] : session[:modells_page]).per_page(12)
    end
  end

  def all_brand_modells
    if params[:modell] && params[:modell][:brand_id].present?
      @brand_modells = Brand.find(params[:modell][:brand_id]).modells
    elsif params[:brand_id].present?
      @brand_modells = Brand.find(params[:brand_id]).modells
    end

    @filter = params[:filter].try(:strip)
    if @filter.present?
      @brand_modells = @brand_modells.where("name ILIKE ?", "%#{@filter}%")
    else
      @brand_modells = @brand_modells.order(:name).page(params[:brand_modells_page].present? ? params[:brand_modells_page] : session[:brand_modells_page]).per_page(12)
    end
  end
end
