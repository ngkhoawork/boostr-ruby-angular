class AgencyDashboard::SpendByAdvertiserSerializer < ActiveModel::Serializer
  has_many :advertisers, serializer: AgencyDashboard::AdvertiserSumsSerializer

  def advertisers
    object
  end

end