class AgencyDashboard::AdvertiserWithoutSpendSumsSerializer < ActiveModel::Serializer
  attributes :id, :advertiser_name, :seller_name, :sum

  private

  def seller_name
    client.max_share_user&.name
  end

  def client
    Client.find(id)
  end
end
