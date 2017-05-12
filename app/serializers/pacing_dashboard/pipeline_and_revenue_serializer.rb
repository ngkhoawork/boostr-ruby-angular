class PacingDashboard::PipelineAndRevenueSerializer < ActiveModel::Serializer
  has_many :time_periods, serializer: PacingDashboard::TimePeriodSerializer

  private

  def time_periods
    object.time_periods.all_quarter
  end
end
