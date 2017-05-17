class PacingDashboard::PipelineAndRevenueSerializer < ActiveModel::Serializer
  attribute :current_week

  has_many :time_periods, serializer: PacingDashboard::TimePeriodSerializer

  private

  def time_periods
    object.time_periods.all_quarter
  end

  def current_week
    TimePeriodWeek.current_week_number if current_time_period?
  end

  def time_period_id
    options[:time_period_id]
  end

  def current_time_period?
    time_period_id.blank? || TimePeriod.current_quarter.id.eql?(time_period_id.to_i)
  end
end
