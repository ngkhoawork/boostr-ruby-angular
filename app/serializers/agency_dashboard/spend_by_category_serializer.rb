class AgencyDashboard::SpendByCategorySerializer < ActiveModel::Serializer
  has_many :categories, serializer: AgencyDashboard::SpendByCategorySumsSerializer

  def categories
    object
  end

end