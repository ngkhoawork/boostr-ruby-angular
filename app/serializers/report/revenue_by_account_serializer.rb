class Report::RevenueByAccountSerializer < ActiveModel::Serializer

  attributes :name,
             :category_id,
             :client_region_id,
             :client_segment_id,
             :team_name,
             :seller_names,
             :year,
             :revenues,
             :total_revenue

  def name
    object.name
  end

  def category_id
    object.category_id
  end

  def client_region_id
    object.client_region_id
  end

  def client_segment_id
    object.client_segment_id
  end

  def team_name
    object.team_name
  end

  def seller_names
    object.seller_names
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
