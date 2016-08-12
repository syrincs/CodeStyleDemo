# encoding: utf-8
class Category < ActiveRecord::Base
  has_ancestry

  belongs_to :descriptiongroup
  has_many :modells, dependent: :destroy
  has_many :searches, dependent: :destroy
  has_many :offers, through: :modells
  has_many :descriptions, through: :descriptiongroup

  validates :name, length: 1..40
  validates :position, numericality: true

  before_validation :sanitize

  def sanitize
    name.try(:strip!)
  end

  def subtree_modells
    Modell.where(category_id: subtree)
  end

  def subtree_offers
    Offer.where(modell_id: subtree_modells)
  end

  def subtree_offers_count
    subtree_offers.count
  end

  def subtree_approved_offers_count
    subtree_offers.approved.count
  end

  def children_count
    children.count
  end

  def path(separator = " / ")
    [ancestors.pluck(:name) << name] * separator
  end
end
