# encoding: utf-8
class DescriptionsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource :descriptiongroup
  load_and_authorize_resource :description, through: :descriptiongroup

  def create
    if @description.save
      redirect_to [@descriptiongroup, :descriptions], notice: _("Description created!")
    else
      render "new"
    end
  end

  def update
    if @description.update_attributes(params[:description])
      redirect_to [@descriptiongroup, :descriptions], notice: _("Description updated!")
    else
      render "edit"
    end
  end

  def destroy
    @description.destroy
    redirect_to [@descriptiongroup, :descriptions], notice: _("Description deleted!")
  end

  protected

  def description_params
    params.require(:description).permit(:abbr, :text)
  end
end
