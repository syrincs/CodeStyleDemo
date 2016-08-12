# encoding: utf-8
class ModellGroupsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @batch = 50
    @offset = params[:offset].to_i
    @filter = params[:filter].try(:strip)
    @modell_groups = @modell_groups.where("name ILIKE ?", "%#{@filter}%") if @filter.present?
    @modell_groups = @modell_groups.offset(@offset)
    @more = [@modell_groups.count - @batch, 0].max
    @modell_groups = @modell_groups.limit(@batch).order(:name)
    render "index_more", :layout => false if params[:remote]
  end

  def create
    if @modell_group.save
      redirect_to modell_groups_path, notice: _("Model group created!")
    else
      render "new"
    end
  end

  def update
    if @modell_group.update_attributes(params[:modell_group])
      redirect_to modell_groups_path, notice: _("Model group updated!")
    else
      render "edit"
    end
  end

  def destroy
    @modell_group.destroy
    redirect_to modell_groups_path, notice: _("Model group deleted!")
  end

  def modells
    @batch = 50
    @offset = params[:offset].to_i
    @filter = params[:filter].try(:strip)
    @modells = @modell_group.modells
    @modells = @modells.where("name ILIKE ?", "%#{@filter}%") if @filter.present?
    @modells = @modells.offset(@offset)
    @more = [@modells.count - @batch, 0].max
    @modells = @modells.limit(@batch).order(:name)
    render "modells_more", :layout => false if params[:remote]
  end

  protected

  def modell_group_params
    params[:modell_group][:modell_ids] = params[:modell_group][:modell_ids].split("|")
    params.require(:modell_group).permit(:name, :modell_ids => [])
  end
end
