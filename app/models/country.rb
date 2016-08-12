# encoding: utf-8
class Country < ActiveRecord::Base
  belongs_to :assigned_employee, :class_name => "User"

  has_many :users, dependent: :destroy
  has_many :offers, as: :location, dependent: :destroy
  has_many :searches, as: :location, dependent: :destroy
  has_and_belongs_to_many :continents

  accepts_nested_attributes_for :continents

  validates :name, length: 1..40

  delegate :count, to: :continents, prefix: true

  def self.for_select
    select([:id, :name]).order(:name).to_a
  end

  def to_s
    name
  end
end

