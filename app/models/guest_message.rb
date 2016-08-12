class GuestMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :phone, :subject, :content
  validates :name, :subject, :content, presence: true
  validates :email, email: true
end
