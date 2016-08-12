# encoding: utf-8
class CurrenciesController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @currencies = Currency.all.page(params[:currencies_page]).per_page(12)
  end

  def create
    if @currency.save
      redirect_to currencies_path, notice: _("Currency created!")
    else
      render "new"
    end
  end

  def update
    if @currency.update_attributes(params[:currency])
      redirect_to currencies_path, notice: _("Currency updated!")
    else
      render "edit"
    end
  end

  def destroy
    @currency.destroy
    redirect_to currencies_path, notice: _("Currency deleted!")
  end

  protected

  def currency_params
    params.require(:currency).permit(:name, :code)
  end
end
