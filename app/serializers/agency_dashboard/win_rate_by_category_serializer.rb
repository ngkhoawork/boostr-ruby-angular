class AgencyDashboard::WinRateByCategorySerializer < ActiveModel::Serializer
  attributes :name, :win_rate
end