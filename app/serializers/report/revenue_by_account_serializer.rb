class Report::RevenueByAccountSerializer < ActiveModel::Serializer

  attributes :id,
             :name,
             :client_type,
             :category_name,
             :region_name,
             :segment_name,
             :team_name,
             :seller_names,
             :revenues,
             :total_revenue

  def id
    object.account_dimension_id
  end

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
    object.client.primary_user&.team&.name
  end

  def seller_names
    object.client.primary_user&.name
  end

  def revenues
    object.month_revenues.values.map(&:to_f)
  end

  def total_revenue
    object.total_revenue.to_f
  end
end
