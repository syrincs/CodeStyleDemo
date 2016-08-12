# encoding: utf-8
class ContinentsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @continents = Continent.all.page(params[:continents_page]).per_page(12)
  end

  def create
    if @continent.save
      redirect_to continents_path, notice: _("Continent created!")
    else
      render "new"
    end
  end

  def update
    if @continent.update_attributes(params[:continent])
      redirect_to continents_path, notice: _("Continent updated!")
    else
      render "edit"
    end
  end

  def destroy
    @continent.destroy
    redirect_to continents_path, notice: _("Continent deleted!")
  end

  protected

  def continent_params
    params.require(:continent).permit(:name, :country_ids => [])
  end
end
