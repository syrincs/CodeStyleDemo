class Incoterm < ActiveRecord::Base
  has_many :offers, dependent: :destroy
  has_many :packages, dependent: :destroy

  validates :name, :presence => true, :length => 1..40
  validates :code, :presence => true, length: 3..10, :uniqueness => true

  before_validation :sanitize

  def self.for_select
    order(:code).map{ |v| ["#{v.code} (#{v.name})", v.id] }
  end

  def sanitize
    self.name = name.strip if name
    self.code = code.strip.upcase if code
  end
end
