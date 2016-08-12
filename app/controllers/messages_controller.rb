# encoding: utf-8
class MessagesController < ApplicationController
  layout :determine_layout

  load_and_authorize_resource

  def inbox
    @batch = 50
    @offset = params[:offset].to_i
    @filter = InboxFilter.new(params[:filter])
    @message_receptions = @filter.list(current_user.message_receptions)
    @message_receptions = @message_receptions.offset(@offset)
    @more = [@message_receptions.count - @batch, 0].max
    @message_receptions = @message_receptions.limit(@batch)
    render "inbox_more", :layout => false if params[:remote]
  end

  def outbox
    @batch = 50
    @offset = params[:offset].to_i
    @filter = params[:filter].try(:strip)
    @messages = current_user.sent_messages
    @messages = @messages.where("subject ILIKE ?", "%#{@filter}%") if @filter.present?
    @messages = @messages.offset(@offset)
    @more = [@messages.count - @batch, 0].max
    @messages = @messages.limit(@batch).order("id DESC")
    render "outbox_more", :layout => false if params[:remote]
  end

  def read
    @message_reception = @message.message_receptions.find_by(:recipient_id => current_user.id)
    @message_reception.read!
    render "read_indicator", :layout => false
  end

  def unread
    @message_reception = @message.message_receptions.find_by(:recipient_id => current_user.id)
    @message_reception.unread!
    render "read_indicator", :layout => false
  end
end
