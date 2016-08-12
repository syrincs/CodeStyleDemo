# encoding: utf-8
class Description < ActiveRecord::Base
  belongs_to :descriptiongroup
  has_many :description_offers, dependent: :destroy
  has_many :offers, through: :description_offers

  validates :abbr, length: 1..100
  validates :text, length: 1..100

  before_validation :sanitize_whitespaces

  def sanitize_whitespaces
    self.abbr = abbr.strip.gsub(/\s+/, " ") if abbr
    self.text = text.strip.gsub(/\s+/, " ") if text
    true
  end
end

