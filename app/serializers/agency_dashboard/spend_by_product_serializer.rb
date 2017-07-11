class AgencyDashboard::SpendByProductSerializer < ActiveModel::Serializer
  has_many :products, serializer: AgencyDashboard::ProductSumsSerializer

  def products
    object
  end

end