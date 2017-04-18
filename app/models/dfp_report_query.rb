class DfpReportQuery < ActiveRecord::Base
  enum report_type: [:cumulative, :monthly]

  belongs_to :api_configuration

  validates_presence_of :report_id
  validates_presence_of :monthly_recurrence_day, if: :monthly?
  validates_presence_of :weekly_recurrence_day, if: :is_cumulative_and_weekly?

  private

  def is_cumulative_and_weekly?
    self.cumulative? && !self.is_daily_recurrent?
  end

end