class DfpReportQuery < ActiveRecord::Base
  enum report_type: [:cumulative, :monthly]
  enum date_range_type: [:last_month, :last_six_month]

  belongs_to :api_configuration

  validates_presence_of :report_id
  validates_presence_of :monthly_recurrence_day, if: :monthly?
  validates_presence_of :weekly_recurrence_day, if: :is_cumulative_and_weekly?
  validate :is_daily_and_weekly, if: :cumulative?

  def get_custom_date_range_bounds
    date_range = { start_date: nil, end_date: DateTime.now }
    case date_range_type
      when 'last_six_month'
        date_range[:start_date] = date_range[:end_date] - 6.month
      when 'last_month'
        date_range[:start_date] = date_range[:end_date] - 1.month
      else
        date_range[:start_date] = date_range[:end_date] - 1.month
    end
    date_range
  end

  private

  def is_cumulative_and_weekly?
    self.cumulative? && !self.is_daily_recurrent?
  end

  def is_daily_and_weekly
    if is_daily_recurrent? && weekly_recurrence_day
      errors.add(:base, 'Cumulative report cannot be weekly and daily, please select one option')
    end
  end

end