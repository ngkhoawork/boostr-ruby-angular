class AgencyDashboard::ProductSumsSerializer < ActiveModel::Serializer
  attributes :date, :name, :sum

  def name
    Product.find(object.top_parent_id).name rescue nil
  end

  def date
    object.start_date.strftime('%Y-%m')
  end

  def sum
    object.sum.to_i
  end

end