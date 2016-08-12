class Currency < ActiveRecord::Base
  has_many :offers, dependent: :destroy
  has_many :packages, dependent: :destroy

  validates :name, :presence => true, :length => 1..40
  validates :code, :presence => true, length: 3..3, :uniqueness => true

  before_validation :sanitize

  def self.for_select
    order(:code).map{ |v| ["#{v.code} (#{v.name})", v.id] }
  end

  def self.update_rates
    body = Net::HTTP.get(URI.parse('http://openexchangerates.org/latest.json?app_id=badf00082f234d87b81605c0a20e6e4f'))
    JSON.parse(body)['rates'].each do |code, rate|
      currency = Currency.find_or_initialize_by(:code => code)
      currency.update_attribute(:rate, rate)
    end
  end

  def self.to_hash
    all.each_with_object({}) do |currency, result|
      result[currency.code] = currency.rate
    end
  end

  def sanitize
    self.name = name.strip if name
    self.code = code.strip.upcase if code
  end
end
