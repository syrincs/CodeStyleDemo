# encoding: utf-8
class CountriesController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @countries = Country.all.page(params[:countries_page]).per_page(12)
  end

  def create
    if @country.save
      redirect_to countries_path, notice: _("Country created!")
    else
      render "new"
    end
  end

  def update
    if @country.update_attributes(params[:country])
      redirect_to countries_path, notice: _("Country updated!")
    else
      render "edit"
    end
  end

  def destroy
    @country.destroy
    redirect_to countries_path, notice: _("Country deleted!")
  end

  protected

  def country_params
    params.require(:country).permit(:name, :assigned_employee_id, :continent_ids => [])
  end
end
