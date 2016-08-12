class Offer < ActiveRecord::Base
  include WithPrice

  STATES = ["waiting_for_buyer", "waiting_reply_seller"]

  belongs_to :creator, class_name: "User"
  belongs_to :user
  belongs_to :currency
  belongs_to :incoterm
  belongs_to :modell
  belongs_to :location, polymorphic: true

  has_many :images, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :description_offers, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy
  has_many :inquiries, as: :buyable, dependent: :destroy
  has_many :property_values, :as => :item, :dependent => :destroy
  has_many :descriptions, lambda{ order("description_offers.id") }, through: :description_offers

  has_and_belongs_to_many :packages
  has_and_belongs_to_many :stocklists

  validates :creator_id, presence: true
  validates :user_id, presence: true
  validates :currency_id, presence: true, if: lambda{ |m| m.user_price && m.user_price > 1 }
  validates :incoterm_id, presence: true, if: lambda{ |m| m.user_price && m.user_price > 1 }
  validates :modell_id, presence: true
  validates :location_id, presence: true
  validates :location_type, presence: true
  validates :user_price, numericality: {greater_than_or_equal_to: 0}
  validates :revenue_percentage, numericality: true
  validates :year, inclusion: {in: lambda{ |attributes| 1950..Date.today.year }}
  validates :in_production, inclusion: [true, false]
  validates :test_possible, inclusion: [true, false]
  validates :complete_and_working, inclusion: [true, false]
  validates :availability, length: 1..60
  validates :year_remarks, length: 0..40
  validates :machine_no, length: 0..40
  validates :serial_no, length: 0..40
  validates :description, length: 0..10_000
  validates :remarks, length: 0..10_000
  validates :user_reference, length: 0..60

  before_validation :sanitize
  before_validation :set_default_revenue_percentage

  before_create :set_last_contact_at
  before_create :set_confirmed
  after_save :update_confirmed_at_of_categories

  delegate :brand, :category, to: :modell, allow_nil: true
  delegate :count, to: :inquiries, prefix: true
  delegate :autologin_secret, to: :user

  state_machine :state, :initial => :waiting_for_buyer do
    state :waiting_for_buyer
    state :waiting_reply_seller
  end

  def self.deleted
    where.not(:deleted_at => nil)
  end

  def self.not_deleted
    where(deleted_at: nil)
  end

  def self.approved
    not_deleted.where.not(:approved_at => nil)
  end

  def self.unapproved
    not_deleted.where(approved_at: nil)
  end

  def self.special
    not_deleted.where(special: true)
  end

  def self.outdated
    not_deleted.where("confirmed_at < ?", 3.months.ago)
  end

  def self.for_confirmation
    not_deleted.where("confirmed_at < ?", 6.weeks.ago).order(:user_reference, :id)
  end

  def self.f_price(from, to)
    scope = all
    scope = scope.where("user_price + user_price * revenue_percentage / 100 >= ?", from) if from
    scope = scope.where("user_price + user_price * revenue_percentage / 100 <= ?", to) if to
    scope
  end

  def self.f_year(from, to)
    scope = all
    scope = scope.where("year >= ?", from) if from
    scope = scope.where("year <= ?", to) if to
    scope
  end

  def self.default_revenue_percentage(price)
    [
      [1_000_000, 6],
      [500_000, 7],
      [100_000, 8],
      [0, 10]
    ].detect{ |v| price >= v[0] }[1]
  end

  def self.ordered(order)
    field, direction = order.split(":")
    ascending = (direction == "asc")
    case field
    when "id"
      query = "id"
      order(ascending ? query : "#{query} DESC")
    when "reference"
      query = "user_reference"
      order(ascending ? query : "#{query} DESC")
    when "created"
      query = "created_at"
      order(ascending ? query : "#{query} DESC")
    when "updated"
      query = "updated_at"
      order(ascending ? query : "#{query} DESC")
    when "price"
      # should be fixed to use selling price
      query = "user_price"
      order(ascending ? query : "#{query} DESC")
    when "age"
      query = "year"
      order(ascending ? query : "#{query} DESC")
    when "format"
      properties = Property.used_as_format.pluck(:id)
      query = "(SELECT value FROM property_values WHERE property_id IN (?) AND item_type = ? AND item_id = modell_id LIMIT 1)"
      order(sanitize_sql([ascending ? query : "#{query} DESC", properties, "Modell"]))
    when "modell"
      query = "(SELECT name FROM modells WHERE id = modell_id)"
      order(ascending ? query : "#{query} DESC")
    when "brand"
      query = "(SELECT b.name FROM brands AS b, modells AS m WHERE b.id = m.brand_id AND m.id = modell_id)"
      order(ascending ? query : "#{query} DESC")
    when "location"
      query = "CASE location_type WHEN 'Continent' THEN (SELECT name FROM continents WHERE id = location_id) ELSE (SELECT name FROM countries WHERE id = location_id) END"
      order(ascending ? query : "#{query} DESC")
    else
      all
    end
  end

  def self.years
    select("DISTINCT year").order(:year).map{ |offer| offer.year }
  end

  def self.per_page
    10
  end

  def self.permanently_delete_old
    where("deleted_at <= ?", 3.months.ago).destroy_all
  end

  def self.ask_updates
    for_confirmation.includes(:user).group_by(&:user).each do |user, offers|
      UserMailer.offers_need_update(user, offers).deliver
    end
  end

  def self.last_message_by_seller
    where(%|user_id = (SELECT sender_id FROM messages WHERE messageable_type = 'Offer' AND messageable_id = offers.id ORDER BY id DESC LIMIT 1)|)
  end

  def self.last_message_by_staff
    where(%|user_id != COALESCE((SELECT sender_id FROM messages WHERE messageable_type = 'Offer' AND messageable_id = offers.id ORDER BY id DESC LIMIT 1), 0)|)
  end

  def deleted?
    !!deleted_at
  end

  def to_s
    "Offer #{id}, a #{brand.name} #{modell.name} from #{year}"
  end

  def set_confirmed
    self.confirmed_at = Time.current
  end

  def update_confirmed_at_of_categories
    return unless confirmed_at_changed?
    ([category] + category.ancestors.to_a).each do |category|
      category.update_attribute(:confirmed_at, confirmed_at)
    end
  end

  def mark_deleted(destroyer)
    return if deleted?
    messages.create_from_template(destroyer, (user_id == destroyer.id) ? 'offer_deleted_by_owner' : 'offer_deleted_by_admin')
    inquiries.each do |inquiry|
      next if inquiry.closed?
      sender = inquiry.assigned_employee
      sender ||= destroyer if destroyer.admin? || destroyer.manager?
      sender ||= User.default_contact
      inquiry.messages.create_from_template(sender, 'inquiry_offer_deleted')
      inquiry.update_attributes!(:state => "closed")
    end
    update_attribute(:deleted_at, Time.current)
  end

  def resurrect(destroyer)
    return unless deleted?
    messages.create_from_template(destroyer, (user_id == destroyer.id) ? 'offer_resurrected_by_owner' : 'offer_resurrected_by_admin')
    inquiries.each do |inquiry|
      sender = inquiry.assigned_employee
      sender ||= destroyer if destroyer.admin? || destroyer.manager?
      sender ||= User.default_contact
      inquiry.messages.create_from_template(sender, 'inquiry_offer_resurrected')
      inquiry.update_attributes!(:state => "waiting_reply_buyer")
    end
    update_attribute(:deleted_at, nil)
  end

  def self.created_by_trusted_user
    joins(:creator).where(:users => {:id => User.trusted_users})
  end

  def created_by_trusted_user?
    User.trusted_users.include?(creator)
  end

  def sanitize
    user_reference.try(:strip!)
    year_remarks.try(:strip!)
    availability.try(:strip!)
    serial_no.try(:strip!)
    machine_no.try(:strip!)
    description.try(:strip!)
    remarks.try(:strip!)
    self.availability = "Immediately" if availability.blank?
    true
  end

  def set_default_revenue_percentage
    return unless user_price
    self.revenue_percentage ||= self.class.default_revenue_percentage(user_price)
  end

  def preview_image
    images.for_index.first
  end

  def format
    modell.format
  end

  def price
    user_price + (revenue || 0)
  end

  def revenue
    return nil unless user_price > 1
    (user_price * (revenue_percentage / 100)).round
  end

  def approved=(value)
    self.approved_at = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value) ? Time.current : nil
  end

  def approved?
    !!approved_at
  end

  def properties
    values = property_values.index_by(&:property_id)
    modell.property_designations.where(:kind => "Offer").order(:id).includes(:property).map do |property_designation|
      property = property_designation.property
      {
        :id => property.id,
        :name => property.name,
        :value => values[property.id].try(:value),
      }
    end
  end

  def open_inquiries_count
    inquiries.open.count
  end

  def approve!(appraiser)
    transaction do
      update_attribute(:approved, true)
      messages.create_from_template(appraiser, 'offer_approved') unless created_by_trusted_user?
    end
  end

  def confirm!
    update_attribute(:confirmed_at, Time.current)
  end

  def similar
    Offer.approved.not_deleted.where(year: (year - 5)..(year + 5), modell_id: modell_id).where.not(:id => id).limit(10)
  end

  def set_last_contact_at
    self.last_contact_at = Time.now
  end

  def contact
    user
  end

  def interested_parties
    [].tap do |list|
      list << user
    end
  end
end
