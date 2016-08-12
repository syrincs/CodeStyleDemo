# encoding: utf-8
class Mailing < ActiveRecord::Base
  serialize :query_locations, JSON
  serialize :query_excluded_locations, JSON

  belongs_to :sender, class_name: "User"

  has_many :mailing_recipients, dependent: :destroy

  validates :subject, length: 1..100
  validates :html, :presence => true, length: 1..50_000
  validates :reply_to, :presence => true, :email => true, length: 1..100

  after_create :schedule_delivery

  def self.pending
    where(:delivery_finished_at => nil)
  end

  def self.perform_delivery
    pending.where("created_at >= ? AND updated_at <= ?", 3.months.ago, 1.hour.ago).each do |mailing|
      mailing.perform_delivery
    end
  end

  def delivered?
    !!delivery_finished_at
  end

  def pending?
    !delivery_started_at
  end

  def in_delivery?
    !pending? && !delivered?
  end

  def prepare_recipients
    recipients = User.where(:newsletter => true)

    if query_locations_objects.any?
      user_ids = []
      query_locations_objects.each{ |location| user_ids.concat(location.users.pluck(:id)) }
      recipients = recipients.where(:id => user_ids.uniq)
    end

    if query_excluded_locations_objects.any?
      user_ids = []
      query_excluded_locations_objects.each{ |location| user_ids.concat(location.users.pluck(:id)) }
      recipients = recipients.where.not(:id => user_ids.uniq)
    end

    recipients = recipients.pluck(:id).map{ |recipient_id| [id, recipient_id] }
    mailing_recipients.import([:mailing_id, :recipient_id], recipients)

    recipients.count
  end

  def prepare_delivery
    update_attributes!(:recipients_count => prepare_recipients)
  end

  def reset_delivery
    transaction do
      self.delivery_started_at = nil
      self.delivery_finished_at = nil
      self.deliveries_count = 0
      save!
      mailing_recipients.completed.each do |mailing_recipient|
        mailing_recipient.undelivered!
      end
    end
  end

  def schedule_delivery
    MailingPreparationWorker.perform_async(id)
  end

  def perform_delivery
    update_delivery_state
    mailing_recipients.pending.pluck(:id).each_slice(100).each do |recipients|
      Rails.logger.info("SendMaillingBulk: #{id}, #{recipients.count}")
      MailingDeliveryWorker.perform_async(id, recipients)
    end
  end

  def deliver_to_recipients(mailing_recipients)
    mailing_recipients.each do |mailing_recipient|
      recipient = mailing_recipient.recipient
      deliver_to_recipient(recipient) if recipient
      mailing_recipient.delivered!
    end
    update_delivery_state
  end

  def update_delivery_state
    self.delivery_started_at ||= Time.now
    self.deliveries_count = mailing_recipients.completed.count
    self.recipients_count = mailing_recipients.count
    self.delivery_finished_at = Time.now if deliveries_count == recipients_count
    save!
  rescue ActiveRecord::StaleObjectError => e
    reload
    retry
  end

  def deliver_to_recipient(recipient)
    options = {
      delivery_method: Rails.configuration.bulk_mailer[:delivery_method],
      from: "ROEPA <no-reply@roepa.com>",
      reply_to: reply_to,
      to: recipient.email,
      subject: view_helper.interpolate(subject, recipient),
      html: view_helper.interpolate(html, recipient),
    }

    begin
      mail = RawMailer.email(options)
      mail.delivery_method.settings.merge!(Rails.configuration.bulk_mailer[:settings])
      mail.deliver
    rescue Net::SMTPSyntaxError, Timeout::Error => e
      # do nothing
    end
  end

  def view_helper
    @view_helper ||= BaseMailer.send(:new)
  end

  def query_locations_objects
    Array(query_locations).map do |item|
      klass, id = item.split(":")
      next nil unless ["Country", "Continent"].include?(klass)
      klass.constantize.find(id)
    end.compact
  end

  def query_excluded_locations_objects
    Array(query_excluded_locations).map do |item|
      klass, id = item.split(":")
      next nil unless ["Country", "Continent"].include?(klass)
      klass.constantize.find(id)
    end.compact
  end
end
