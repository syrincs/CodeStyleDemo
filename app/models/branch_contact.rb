# encoding: utf-8
class BranchContact < ActiveRecord::Base
  belongs_to :branch

  validates :name, length: 1..40
  validates :phone, length: 0..40
  validates :mobile, length: 0..40
  validates :fax, length: 0..40
  validates :email, length: 0..40, email: true, if: lambda { |m| m.email.present? }
end

