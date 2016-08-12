# encoding: utf-8
class Inquiry < ActiveRecord::Base
  STATES = ["waiting_reply_staff", "waiting_reply_buyer", "closed"]

  belongs_to :user
  belongs_to :buyable, polymorphic: true
  belongs_to :assigned_employee, class_name: "User"
  belongs_to :creator, :class_name => "User"

  has_many :messages, as: :messageable, dependent: :destroy

  validates :creator_id, :presence => true
  validates :user_id, :presence => true, uniqueness: {scope: [:buyable_type, :buyable_id]}
  validates :buyable_id, presence: true
  validates :buyable_type, :presence => true, :inclusion => ["Offer", "Package"]
  validates :state, :presence => true, :inclusion => STATES

  delegate :autologin_secret, to: :user

  before_create :set_last_contact_at
  after_save :assign_messages_to_new_assigned_employee, :if => lambda{ |m| m.assigned_employee_id_changed? }

  state_machine :state, :initial => :waiting_reply_staff do
    state :waiting_reply_staff
    state :waiting_reply_buyer
    state :closed
  end

  def self.find_by_buyable_and_user(buyable, user)
    where(buyable_type: buyable.class.name, buyable_id: buyable.id, user_id: user.id).first
  end

  def self.closed
    where(:state => ["closed"])
  end

  def self.not_closed
    where.not(:state => ["closed"])
  end

  def self.open
    where(:state => ["waiting_reply_staff", "waiting_reply_buyer"])
  end

  def set_last_contact_at
    self.last_contact_at = Time.now
  end

  def to_s
    "Inquiry #{id} - #{buyable}"
  end

  def contact
    user
  end

  def open?
    !closed?
  end

  def seller
    buyable.user
  end

  def interested_parties
    [].tap do |list|
      list << user
      list << assigned_employee if assigned_employee
    end
  end

  def assign_messages_to_new_assigned_employee
    messages.each{ |message| message.create_message_receptions }
  end
end
