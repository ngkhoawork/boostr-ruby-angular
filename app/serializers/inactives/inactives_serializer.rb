class Inactives::InactivesSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :average_quarterly_spend,
    :open_pipeline,
    :sellers
  )

  has_one :latest_advertiser_activity, key: :last_activity, serializer: Inactives::LastActivitySerializer

  def average_quarterly_spend
    total_revenue = @options[:total_revenues].find{|el| el[:account_dimension_id] == object.id}
    (total_revenue[:total_revenue] / (@options[:spend_range_length])).round(0).to_f
  end

  def open_pipeline
    object.advertiser_deals_open_pipeline || 0
  end

  def sellers
    object.users.select do |user|
      user.user_type == SELLER ||
      user.user_type == SALES_MANAGER
    end.map(&:name).sort
  end
end
