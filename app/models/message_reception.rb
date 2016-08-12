# encoding: utf-8
class MessageReception < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient, :class_name => "User"

  validates :message_id, presence: true
  validates :recipient_id, presence: true

  def read?
    !!read_at
  end

  def read!
    return if read?
    update_attributes!(:read_at => Time.now)
  end

  def unread!
    return unless read?
    update_attributes!(:read_at => nil)
  end
end
