# encoding: utf-8
class Branch < ActiveRecord::Base
  belongs_to :country

  has_many :contacts, dependent: :destroy, class_name: 'BranchContact'

  validates :name, length: 1..40
  validates :address, length: 1..1000
  validates :country, presence: true
  validates :description, length: 1..1000
  validates :location, length: 1..100
  validates :languages, length: 1..100

  delegate :count, to: :contacts, prefix: true
end

