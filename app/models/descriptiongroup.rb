# encoding: utf-8
class Descriptiongroup < ActiveRecord::Base
  has_many :descriptions, dependent: :destroy
  has_many :categories

  validates :name, presence: true, length: 1..40

  delegate :count, to: :descriptions, prefix: true

  def self.for_select
    select([:id, :name]).order(:name).to_a
  end
end

