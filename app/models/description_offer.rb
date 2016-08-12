# encoding: utf-8
class DescriptionOffer < ActiveRecord::Base
  belongs_to :description
  belongs_to :offer
end

