# encoding: utf-8
class LoginsController < ApplicationController
  layout :determine_layout
  
  load_and_authorize_resource

  def index
    @batch = 25
    @batch = params[:filter][:shown_items].to_i if params[:filter] && params[:filter][:shown_items].present?
    @filter = LoginFilter.new(params[:filter])
    @logins = @filter.list.page(params[:logins_page]).per_page(@batch)
  end
end
