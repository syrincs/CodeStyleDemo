# encoding: utf-8
class BranchContactsController < ApplicationController
  layout :determine_layout

  load_and_authorize_resource :branch
  load_and_authorize_resource :branch_contact, through: :branch, through_association: :contacts

  before_action :all_branch_contacts, only: [:index, :create, :update, :destroy]

  def create
    if @branch_contact.save
      flash.now[:success] = _("Contact created!")
      redirect_to [@branch, :branch_contacts], success: _("Contact created!")
    else
      render "new"
    end
  end

  def update
    if @branch_contact.update_attributes(params[:branch_contact])
      redirect_to [@branch, :branch_contacts], success: _("Contact updated!")
    else
      render "edit"
    end
  end

  def destroy
    respond_to do |format|
      @branch_contact.destroy!
      flash.now[:success] = _("Contact deleted!")

      format.js
      format.html { redirect_to [@branch, :branch_contacts], success: _("Contact deleted!") }
    end
  end

  protected

  def branch_contact_params
    params.require(:branch_contact).permit(:name, :phone, :mobile, :fax, :email, :position)
  end

  def all_branch_contacts
    @branch_contacts = Branch.find(@branch.id).contacts.order(:name)
  end
end
