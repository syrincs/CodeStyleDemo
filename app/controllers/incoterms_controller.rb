# encoding: utf-8
class IncotermsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @incoterms = Incoterm.all.page(params[:incoterms_page]).per_page(12)
  end

  def create
    if @incoterm.save
      redirect_to incoterms_path, notice: _("Incoterm created!")
    else
      render "new"
    end
  end

  def update
    if @incoterm.update_attributes(params[:incoterm])
      redirect_to incoterms_path, notice: _("Incoterm updated!")
    else
      render "edit"
    end
  end

  def destroy
    @incoterm.destroy
    redirect_to incoterms_path, notice: _("Incoterm deleted!")
  end

  protected

  def incoterm_params
    attributes = [:name, :code]
    params.require(:incoterm).permit(attributes)
  end
end
