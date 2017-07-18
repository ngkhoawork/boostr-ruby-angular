class AgencyDashboard::AdvertiserWithoutSpendSumsSerializer < ActiveModel::Serializer
  attributes :id, :advertiser_name, :seller_name, :sum
end