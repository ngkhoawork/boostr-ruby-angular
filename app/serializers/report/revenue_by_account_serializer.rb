class Report::RevenueByAccountSerializer < ActiveModel::Serializer

  attributes :name,
             :client_type,
             :category_name,
             :region_name,
             :segment_name,
             :team_name,
             :seller_names,
             :revenues,
             :total_revenue

  def name
    object.name
  end

  def client_type
    AccountDimension.account_types.to_hash.invert[object.client_type]
  end

  def category_name
    object.client_category_name
  end

  def region_name
    object.client_region_name
  end

  def segment_name
    object.client_segment_name
  end

  def team_name
    object.team_name
  end

  def seller_names
    object.seller_names.join(', ')
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
