# encoding: utf-8
class MailingRecipient < ActiveRecord::Base
  belongs_to :mailing
  belongs_to :recipient, :class_name => "User"

  validates :mailing_id, presence: true
  validates :recipient_id, presence: true

  def self.pending
    where(delivered: false)
  end

  def self.completed
    where(delivered: true)
  end

  def delivered!
    update_attribute(:delivered, true)
  end

  def undelivered!
    update_attribute(:delivered, false)
  end
end

