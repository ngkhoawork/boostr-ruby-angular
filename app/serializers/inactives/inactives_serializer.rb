class Inactives::InactivesSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :client_name,
    :average_quarterly_spend,
    :open_pipeline,
    :last_activity,
    :sellers
  )

  def client_name
    object.name
  end

  def average_quarterly_spend
    total_revenue = @options[:total_revenues].find{|el| el[:account_dimension_id] == object.id}
    (total_revenue[:total_revenue] / (@options[:spend_range_length])).round(0).to_f
  end

  def open_pipeline
    object
      .advertiser_deals
      .open
      .pluck(:budget)
      .compact
      .reduce(:+)
      &.round(0) || 0
  end

  def last_activity
    object.latest_advertiser_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment])
  end

  def sellers
    object.users.select do |user|
      user.user_type == SELLER ||
      user.user_type == SALES_MANAGER
    end.map(&:name).sort
  end
end
