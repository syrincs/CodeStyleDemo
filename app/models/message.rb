# encoding: utf-8
class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :messageable, polymorphic: true

  has_many :message_receptions, :dependent => :destroy

  validates :sender_id, presence: true
  validates :messageable_id, presence: true
  validates :messageable_type, presence: true, :inclusion => ["Inquiry", "Offer"]
  validates :subject, presence: true, :length => 1..200
  validates :html, presence: true, :length => 1..100_000

  before_validation :set_default_subject
  before_save :interpolate

  after_create :update_last_contact_on_messageable
  after_create :create_message_receptions

  def self.create_from_template(sender, template, send_by_email = true)
    new(:sender => sender, :generated => true).tap do |message|
      message.set_html_from_template(template)
      if send_by_email
        message.send_by_email
      end
      message.save!
    end
  end

  def set_default_subject
    return if subject.present? || !messageable
    self.subject = messageable.to_s
  end

  def interpolate
    write_attribute(:html, ViewHelper.interpolate(html, recipient, messageable))
  end

  def html=(value)
    html = Nokogiri::HTML(value || "")
    element = html.css("div.content").first || html.css("body").first || html
    write_attribute(:html, HtmlTool.sanitize(element.inner_html))
  end

  def text=(value)
    self.html = ViewHelper.simple_format(ViewHelper.h(value))
  end

  def update_last_contact_on_messageable
    messageable.update_attributes!(:last_contact_at => created_at)
  end

  def create_message_receptions
    recipients = messageable.messages.map(&:sender)
    recipients.concat(messageable.interested_parties)
    recipients.uniq!
    recipients.each do |recipient|
      next if recipient == sender
      next if message_receptions.where(:recipient_id => recipient.id).exists?
      message_receptions.create!(:recipient => recipient)
    end
  end

  def recipient
    messageable.contact
  end

  def send_by_email
    case messageable
    when Inquiry
      inquiry = messageable
      subject = "Inquiry #{inquiry.id} - #{ViewHelper.buyable(inquiry.buyable)}"
    when Offer
      offer = messageable
      subject = "Offer #{offer.id} - #{offer.brand.name} #{offer.modell.name} from #{offer.year}"
      subject << " (your reference #{offer.user_reference})" if offer.user_reference.present?
    else
      raise ArgumentError, "invalid messageable_type #{messageable_type}"
    end
    RawMailer.email(:to => "#{recipient.name} <#{recipient.email}>", :from => "#{sender.name} <#{sender.email}>", :subject => subject, :html => html).deliver
    update_attributes!(:emailed_at => Time.now)
  end

  def set_html_from_template(template)
    locals = {
      :message => self,
      :"#{messageable_type.underscore}" => messageable,
    }
    html = ViewHelper.render_to_string("messages/#{template}", :locals => locals)
    update_attributes!(:html => html)
  end
end
