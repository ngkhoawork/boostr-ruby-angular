class AgencyDashboard::AdvertiserWithoutSpendSumsSerializer < ActiveModel::Serializer
  attributes :advertiser_name, :seller_name, :sum
end