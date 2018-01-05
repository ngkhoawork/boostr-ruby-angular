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

  def revenue_lifetime
    object.daily_actuals.to_a.sum(&:total_revenue) rescue nil
  end

  def revenue_ytd
    object.daily_actuals_for_current_year.to_a.sum(&:total_revenue) rescue nil
  end

  def last_export_date
    object.last_daily_actual&.created_at
  end

  def fill_rate
    return 0 if sum_of_filled_impressions.zero?

    (100 / sum_of_available_impressions.to_f * sum_of_filled_impressions).round(1)
  end

  def sum_of_available_impressions
    daily_actuals_for_past_90_days.sum(:available_impressions)
  end

  def sum_of_filled_impressions
    daily_actuals_for_past_90_days.sum(:filled_impressions)
  end

  def actual_monthly_impressions
    daily_actuals_for_past_90_days.sum(:available_impressions) / 3 rescue nil
  end

  def daily_actuals_for_past_90_days
    @_daily_actuals_for_past_90_days ||= object.daily_actuals.by_date(Date.current - 90.days, Date.current)
  end
end
