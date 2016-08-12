# encoding: utf-8
class Brand < ActiveRecord::Base
  has_many :modells, dependent: :destroy
  has_many :searches, dependent: :destroy
  has_many :offers, through: :modells

  validates :name, length: 1..40

  delegate :count, to: :modells, prefix: true
  delegate :count, to: :offers, prefix: true

  def self.popular
    select("brands.id, brands.name, COUNT(offers.id) AS offers_count").joins(:offers).group("brands.id").order("offers_count DESC")
  end

  def self.with_offers
    where(Modell.where("brand_id = brands.id").with_offers.exists)
  end

  def self.for_select
    select([:id, :name]).order(:name).to_a
  end

  def self.for_search_select(category_id)
    scope = where(Modell.with_offers.where("brand_id = brands.id").exists)
    if category_id && category_id > 0
      scope = scope.where(id: Category.find(category_id).subtree_modells.select([:brand_id]))
    end
    scope.for_select.map{ |v| [v.name, v.id] }
  end

  def self.f_name(name)
    where("name ILIKE ?", "%#{name}%")
  end

  def self.offers
    Modell.f_brand_id(all).offers
  end

  def self.per_page
    100
  end
end

