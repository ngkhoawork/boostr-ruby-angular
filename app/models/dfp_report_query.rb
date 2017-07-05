class DfpReportQuery < ActiveRecord::Base
  enum report_type: [:cumulative, :monthly]

  belongs_to :api_configuration

  validates_presence_of :report_id
  validates_presence_of :monthly_recurrence_day, if: :monthly?
  validates_presence_of :weekly_recurrence_day, if: :is_cumulative_and_weekly?
  validate :is_daily_and_weekly, if: :cumulative?

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