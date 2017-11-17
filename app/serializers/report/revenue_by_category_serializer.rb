class Report::RevenueByCategorySerializer < ActiveModel::Serializer

  attributes :category_name, :year, :revenues, :total_revenue

  def category_name
    object.client_category_name
  end

  def year
    object.year.to_i
  end

  def revenues
    revenues_to_f!
    object.month_revenues
  end

  def total_revenue
    object.total_revenue.to_f
  end

  private

  def revenues_to_f!
    object.month_revenues.each { |k, v| object.month_revenues[k] = v.to_f  }
  end
end
