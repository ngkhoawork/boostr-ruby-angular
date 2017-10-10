class AgencyDashboard::SpendByCategorySumsSerializer < ActiveModel::Serializer
    attributes :category_name, :sum
end