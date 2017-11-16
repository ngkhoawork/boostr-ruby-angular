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
    Option.find(object.category_id).name if object.category_id
  end

  def region_name
    Option.find(object.client_region_id).name if object.client_region_id
  end

  def segment_name
    Option.find(object.client_segment_id).name if object.client_segment_id
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
