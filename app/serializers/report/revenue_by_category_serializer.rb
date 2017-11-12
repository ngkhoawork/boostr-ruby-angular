class Report::RevenueByCategorySerializer < ActiveModel::Serializer

  attributes :category_id, :year, :revenues, :total_revenue

  def attributes(*args)
    super.compact
  end

  def category_id
    object.category_id
  end

  def year
    object.year.to_i
  end

  def revenues
    revenues_to_f!
    object.revenues
  end

  def total_revenue
    object.total_revenue.to_f
  end

  private

  def revenues_to_f!
    object.revenues.each { |k, v| object.revenues[k] = v.to_f  }
  end
end
