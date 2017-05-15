class TimePeriodWeek < ActiveRecord::Base
  scope :by_period_start_and_end, -> start_date, end_date { where(period_start: start_date, period_end: end_date) }

  def self.current_week_number
    find_by('start_date <= ? AND end_date >= ?', Date.current, Date.current).week
  end
end
