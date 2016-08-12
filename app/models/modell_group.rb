class ModellGroup < ActiveRecord::Base
  has_many :modells, :dependent => :nullify
  has_many :offers, :through => :modells

  validates :name, :presence => true, :length => 1..100

  before_validation :sanitize

  delegate :count, to: :modells, prefix: true
  delegate :count, to: :offers, prefix: true

  def sanitize
    self.name = name.strip if name
  end
end
