# encoding: utf-8
class Login < ActiveRecord::Base
  STATI = ["success", "failure"]

  belongs_to :user

  validates :user_id, :presence => true
  validates :status, :presence => true, :inclusion => STATI
  validates :ip, :presence => true, :length => 7..15

  before_create :resolve_ip

  def resolve_ip
    self.country = geo_ip.country(ip).try(:country_name) || ""
    self.country = "" if country == "N/A"

    self.country_code = geo_ip.country(ip).try(:country_code2) || ""
    self.country_code = "" if country_code == "--"
  end

  protected

  def geo_ip
    @geo_ip ||= GeoIP.new(Rails.root.join("vendor", "GeoIP.dat"))
  end
end
