class Modell < ActiveRecord::Base
  belongs_to :brand
  belongs_to :category
  belongs_to :modell_group

  has_many :offers, dependent: :destroy
  has_many :serials, class_name: "Modell::Serial", dependent: :destroy
  has_many :searches, dependent: :destroy
  has_many :property_designations, dependent: :destroy
  has_many :property_values, as: :item, dependent: :destroy

  accepts_nested_attributes_for :serials, allow_destroy: true, reject_if: lambda{ |attrs| attrs[:year].blank? && attrs[:serial].blank? }

  validates :name, length: 1..40
  validates :brand_id, presence: true
  validates :category_id, presence: true

  delegate :count, to: :offers, prefix: true

  def self.for_select
    select([:id, :name]).order(:name).to_a
  end

  def self.popular
    select("modells.id, modells.name, COUNT(offers.id) AS offers_count").joins(:offers).group("modells.id").order("offers_count DESC")
  end

  def self.with_offers
    where(Offer.where("modell_id = modells.id").approved.exists)
  end

  def self.scope_for_search_select(category_id, brand_id)
    scope = with_offers
    if category_id && category_id > 0
      scope = scope.where(category_id: Category.find(category_id).subtree)
    end
    if brand_id && brand_id > 0
      scope = scope.where(brand_id: brand_id)
    end
    scope
  end

  def self.for_search_select(category_id, brand_id)
    scope = scope_for_search_select(category_id, brand_id)
    scope.for_select.map{ |v| [v.name, v.id] }
  end

  def self.formats_for_search_select(category_id, brand_id, modell_id)
    scope = scope_for_search_select(category_id, brand_id)
    if modell_id && modell_id > 0
      scope = scope.where(id: modell_id)
    end
    properties = Property.used_as_format.pluck(:id)
    PropertyValue.distinct.where(item_type: "Modell", item_id: scope, property_id: properties).order(:value).pluck(:value)
  end

  def self.f_name(name)
    where("name ILIKE ?", "%#{name}%")
  end

  def self.f_brand_id(brand_id)
    where(brand_id: brand_id)
  end

  def self.f_format(format)
    properties = Property.used_as_format.pluck(:id)
    where(id: PropertyValue.where(item_type: "Modell", property_id: properties, value: format).select(:item_id))
  end

  def self.offers
    Offer.where(modell_id: all)
  end

  def self.formats
    formats_for_search_select(nil, nil, nil)
  end

  def format
    properties = Property.used_as_format.pluck(:id)
    property_values.where(property_id: properties).pluck(:value).first
  end

  def properties
    values = property_values.index_by(&:property_id)
    property_designations.where(kind: "Modell").order(:id).includes(:property).map do |property_designation|
      property = property_designation.property
      {
        id: property.id,
        name: property.name,
        value: values[property.id].try(:value),
      }
    end
  end

  def clone!
    dup.tap do |modell|
      transaction do
        modell.update_attributes!(name: "#{name} clone")
        modell.property_designations << property_designations.order(:id).map{ |v| v.dup }
        modell.property_values << property_values.map{ |v| v.dup }
      end
    end
  end
end

