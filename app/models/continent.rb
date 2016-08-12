# encoding: utf-8
class Continent < ActiveRecord::Base
  has_many :offers, as: :location, dependent: :destroy
  has_many :searches, as: :location, dependent: :destroy

  has_and_belongs_to_many :countries

  has_many :users, :through => :countries

  accepts_nested_attributes_for :countries

  validates :name, length: 1..40

  delegate :count, to: :countries, prefix: true

  def self.for_select
    select([:id, :name]).order(:name).to_a
  end

  def to_s
    name
  end
end

