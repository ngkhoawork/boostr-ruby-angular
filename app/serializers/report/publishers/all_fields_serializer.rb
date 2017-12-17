class Report::Publishers::AllFieldsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :publisher_stage,
    :client,
    :teams,
    :fill_rate,
    :revenue_lifetime,
    :revenue_ytd,
    :last_export_date,
    :created_at,
    :updated_at
  )

  has_one :publisher_custom_field

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def publisher_stage
    object.publisher_stage&.name
  end

  def client
    object.client&.serializable_hash(only: [:id, :name])
  end

  def teams
    object.users.map { |user| user.team&.serializable_hash(only: [:id, :name]) }.compact
  end

  def fill_rate
    return 0 if fill_rate_sum_for_previous_month.zero?

    (fill_rate_sum_for_previous_month / object.daily_actuals_for_previous_month.size).round(1)
  end

  def revenue_lifetime
    object.daily_actuals.to_a.sum(&:total_revenue)
  end

  def revenue_ytd
    object.daily_actuals_for_current_year.to_a.sum(&:total_revenue)
  end

  def last_export_date
    object.last_daily_actual&.created_at
  end

  def fill_rate_sum_for_previous_month
    @_fill_rate_sum ||= object.daily_actuals_for_previous_month.to_a.sum(&:fill_rate)
  end
end
