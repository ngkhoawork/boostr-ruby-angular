class AgencyDashboard::AdvertisersWithoutSpendSerializer < ActiveModel::Serializer
  has_many :advertisers, serializer: AgencyDashboard::AdvertiserWithoutSpendSumsSerializer

  def advertisers
    object
  end

end