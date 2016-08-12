# encoding: utf-8
class ImagesController < ApplicationController
  load_and_authorize_resource :offer
  load_and_authorize_resource :image, through: :offer

  def create
    @image.uploader = current_user
    @image.data = params[:file]
    @image.remarks = params[:comment]
    @image.save!
    render nothing: true
  end

  def update
    @success = @image.update_attributes(params[:image])
  end

  def destroy
    @image.destroy
  end

  protected

  def image_params
    attributes = [:remarks]
    params.require(:image).permit(attributes)
  end
end
