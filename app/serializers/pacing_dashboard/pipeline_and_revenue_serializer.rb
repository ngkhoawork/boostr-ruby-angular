class PacingDashboard::PipelineAndRevenueSerializer < ActiveModel::Serializer
  attribute :current_week

  has_many :time_periods, serializer: PacingDashboard::TimePeriodSerializer

  private

  def time_periods
    object.time_periods.all_quarter
  end

  def current_week
    TimePeriodWeek.current_week_number
  end
end
