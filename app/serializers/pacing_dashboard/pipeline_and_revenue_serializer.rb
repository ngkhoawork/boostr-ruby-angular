class PacingDashboard::PipelineAndRevenueSerializer < ActiveModel::Serializer
  attribute :current_week
  attribute :max_quota

  has_many :time_periods, serializer: PacingDashboard::TimePeriodSerializer

  def current_week
    TimePeriodWeek.current_week_number if current_time_period?
  end

  def max_quota
    quotas.sum(:value)
  end

  def time_periods
    company.time_periods.all_quarter
  end

  private

  def time_period_id
    options[:time_period_id]
  end

  def current_time_period?
    time_period_id.blank? || TimePeriod.current_quarter.id.eql?(time_period_id.to_i)
  end

  def time_period
    time_period_id.blank? ? TimePeriod.current_quarter : TimePeriod.find(time_period_id)
  end

  def quotas
    company.quotas.by_type('gross').where(time_period: time_period, user: leader_ids)
  end

  def leader_ids
    company.teams.leader_ids
  end

  def company
    @_company ||= object
  end
end
