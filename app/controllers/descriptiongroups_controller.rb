# encoding: utf-8
class DescriptiongroupsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def create
    if @descriptiongroup.save
      redirect_to descriptiongroups_path, notice: _("Description group created!")
    else
      render "new"
    end
  end

  def update
    if @descriptiongroup.update_attributes(params[:descriptiongroup])
      redirect_to descriptiongroups_path, notice: _("Description group updated!")
    else
      render "edit"
    end
  end

  def destroy
    @descriptiongroup.destroy
    redirect_to descriptiongroups_path, notice: _("Description group deleted!")
  end

  protected

  def descriptiongroup_params
    params.require(:descriptiongroup).permit(:name)
  end
end
