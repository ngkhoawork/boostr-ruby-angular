class AgencyDashboard::AdvertiserWithoutSpendSumsSerializer < ActiveModel::Serializer
  attributes :id, :advertiser_name, :seller_name, :sum

  private

  def seller_name
    Client.max_share_user(id).first.name
  end

end