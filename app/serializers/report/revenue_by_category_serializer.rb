class Report::RevenueByCategorySerializer < ActiveModel::Serializer

  attributes :category_id, :year, :revenues, :total_revenue, :region_id, :segment_id

  def attributes(*args)
    super(*args).compact
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

  def region_id
    object.try(:region_id)
  end

  def segment_id
    object.try(:segment_id)
  end

  private

  def revenues_to_f!
    object.revenues.each { |k, v| object.revenues[k] = v.to_f  }
  end
end
