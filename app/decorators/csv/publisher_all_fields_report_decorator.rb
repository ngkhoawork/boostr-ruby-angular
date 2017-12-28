class Csv::PublisherAllFieldsReportDecorator
  DELEGATE_TO_PUBLISHER_ATTRIBUTES =
    %i(
      id
      name
      comscore
      website
      estimated_monthly_impressions
    ).freeze

  def initialize(record)
    @record = record
  end

  DELEGATE_TO_PUBLISHER_ATTRIBUTES.each do |method_name|
    define_method(method_name) do
      record.send(method_name)
    end
  end

  def type
    record.type&.name
  end

  def publisher_stage
    record.publisher_stage&.name
  end

  def client
    record.client&.name
  end

  def created_at
    record.created_at.to_date
  end

  def monthly_impressions_90_day_avg
    daily_actuals_for_past_90_days.sum(:available_impressions) / 3 rescue nil
  end

  def fill_rate_90_day_avg
    return '0%' if sum_of_filled_impressions.zero?

    "#{(100 / sum_of_available_impressions.to_f * sum_of_filled_impressions).round(1)}%"
  end

  def revenue_lifetime
    return '$0' if sum_revenue_lifetime.zero?

    "#{curr_symbol}#{sum_revenue_lifetime}"
  end

  def revenue_ytd
    return '$0' if sum_revenue_ytd.zero?

    "#{curr_symbol}#{sum_revenue_ytd}"
  end

  def export_date
    Date.current
  end

  def custom_fields
    return unless record.publisher_custom_field

    FlatPublisherCustomFieldSerializer.new(record.publisher_custom_field).attributes
  end

  private

  attr_reader :record

  def curr_symbol
    record.daily_actuals.first&.currency&.curr_symbol
  end

  def sum_revenue_lifetime
    @_sum_revenue_lifetime ||= record.daily_actuals.to_a.sum(&:total_revenue) rescue 0
  end

  def sum_revenue_ytd
    @_sum_revenue_ytd ||= record.daily_actuals_for_current_year.to_a.sum(&:total_revenue) rescue 0
  end

  def daily_actuals_for_past_90_days
    @_daily_actuals_for_past_90_days ||= record.daily_actuals.by_date(Date.current - 90.days, Date.current)
  end

  def sum_of_available_impressions
    daily_actuals_for_past_90_days.sum(:available_impressions)
  end

  def sum_of_filled_impressions
    daily_actuals_for_past_90_days.sum(:filled_impressions)
  end
end
