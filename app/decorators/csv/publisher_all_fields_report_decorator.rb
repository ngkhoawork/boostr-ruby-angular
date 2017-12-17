class Csv::PublisherAllFieldsReportDecorator
  DELEGATE_TO_PUBLISHER_ATTRIBUTES =
    %i(
      id
      name
      comscore
      website
      actual_monthly_impressions
      estimated_monthly_impressions
    ).freeze

  def initialize(record)
    @record = record
  end

  DELEGATE_TO_PUBLISHER_ATTRIBUTES.each do |method_name|
    define_method(method_name) do
      @record.send(method_name)
    end
  end

  def type
    @record.type&.name
  end

  def publisher_stage
    @record.publisher_stage&.name
  end

  def client
    @record.client&.name
  end

  def created_at
    @record.created_at.to_date
  end

  def fill_rate
    return 0 if fill_rate_sum_for_previous_month.zero?

    (fill_rate_sum_for_previous_month / @record.daily_actuals_for_previous_month.size).round(1)
  end

  def revenue_lifetime
    @record.daily_actuals.to_a.sum(&:total_revenue)
  end

  def revenue_ytd
    @record.daily_actuals_for_current_year.to_a.sum(&:total_revenue)
  end

  def last_export_date
    @record.last_daily_actual&.created_at
  end

  def custom_fields
    return unless @record.publisher_custom_field

    FlatPublisherCustomFieldSerializer.new(@record.publisher_custom_field).attributes
  end

  private

  def fill_rate_sum_for_previous_month
    @_fill_rate_sum ||= @record.daily_actuals_for_previous_month.to_a.sum(&:fill_rate)
  end
end
