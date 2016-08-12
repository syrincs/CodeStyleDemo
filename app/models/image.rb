# encoding: utf-8
class Image < ActiveRecord::Base
  TYPES = ["Original", "Archive", "Wide"]

  belongs_to :offer
  belongs_to :uploader, :class_name => "User"

  mount_uploader :data, ImageUploader

  validates :data, presence: true
  validates :remarks, inclusion: TYPES

  delegate :preview, :normal, to: :data
  delegate :url, to: :preview, prefix: true
  delegate :url, to: :normal, prefix: true

  after_create :confirm_offer

  def self.for_index
    order(:order).to_a
  end

  def self.types
    TYPES
  end

  def self.wide
    where(:remarks => "Wide")
  end

  def self.normal
    where.not(:remarks => "Wide")
  end

  def confirm_offer
    offer.confirm!
  end
end

