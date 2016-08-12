# encoding: utf-8
class BranchesController < ApplicationController
  layout :determine_layout
  load_and_authorize_resource

  before_action :all_branches, only: [:index, :create, :update, :destroy]

  def index
    session[:branches_page] = params[:branches_page] if params[:branches_page]
    #render partial: "index", locals: { branches: @branches }, layout: false if params[:remote]
  end

  def create
    respond_to do |format|
      @branch.location = params[:query] if params[:query]
      if @branch.save
        flash.now[:success] = _("Branch created!")

        format.js
        format.html { redirect_to branches_path, success: _("Branch created!") }    
      else
        flash.now[:alert] = "Creating branch failed!" 
        format.js { render "new" }
        format.html { render "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @branch.update_attributes(params[:branch])
        flash.now[:success] = _("Branch updated!")

        format.html { redirect_to properties_path, success: _("Branch updated!") }
        format.js
      else
        format.js { render "edit" }
        format.html { render "edit" }
      end
    end
  end

  def destroy
    respond_to do |format|
      @branch.destroy!
      flash.now[:success] = _("Branch deleted!")
      format.js
      format.html { redirect_to branches_path, success: _("Branch deleted!") }
    end
  end

  def show
    @guest_message = GuestMessage.new
    render layout: "screen2015"
  end

  def send_mail
    @guest_message = GuestMessage.new(params[:guest_message])

    if @guest_message.valid?
      deliver_mail(@guest_message.name, @guest_message.subject, @guest_message.email, @guest_message.phone, @guest_message.content)
      redirect_to branch_path, success: "Thank you for your message. We will get in touch with you."
    else
      render :show
    end
  end

  protected

  def branch_params
    params.require(:branch).permit(:name, :address, :country_id, :description, :location, :languages, :position)
  end

  def deliver_mail(name, subject, email, phone, content)
      ActionMailer::Base.mail(from: "#{name} <info@roepa.com>", to: "horst@roepa.com", reply_to: email, subject: subject, body: "PhoneNumber: #{phone} \n\n #{content}").deliver
  end

  def all_branches
    @branches = Branch.all.order(:name).page(params[:branches_page].present? ? params[:branches_page] : session[:branches_page]).per_page(12)
  end
end
