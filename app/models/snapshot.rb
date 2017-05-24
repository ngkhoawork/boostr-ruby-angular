class Snapshot < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  before_create :snap_weighted_pipeline
  before_create :snap_revenue

  before_save :set_dates

  # NOTE: if there are two duplicate time periods this will probably break (ideally we would use the time_period_id to group them and grab from a single group)
  scope :two_recent_for_time_period, -> (start_date, end_date) { where('snapshots.start_date = ? AND snapshots.end_date = ?', start_date, end_date).order('created_at DESC').limit(2) }
  scope :two_recent_for_year_and_quarter, -> (year, quarter) { where('snapshots.year = ? AND snapshots.quarter = ?', year, quarter).order('created_at DESC').limit(2) }
  scope :by_company_in_period, -> (company, period, start_date, end_date) do
    where(
      company: company,
      created_at: start_date.beginning_of_day..end_date.end_of_day,
      time_period: period
    )
  end
  scope :grouped_by_day_in_period_for_company, -> do
    select(:id, :created_at, :revenue, :weighted_pipeline)
    .group("date_trunc('day', created_at)")
    .order('date_trunc_day_created_at')
  end

  validates :company, :user, :time_period, presence: true

  def self.generate_snapshot(company, user, time_period, year, quarter)
    Snapshot.create(company: company, user: user, time_period: time_period, year: year, quarter: quarter)
  end

  def self.generate_snapshots(company)
    company.users.each do |user|
      company.time_periods.each do |time_period|
        Snapshot.generate_snapshot(company, user, time_period, nil, nil)
      end
      # TODO: we need better year selection logic
      [2016, 2017].each do |year|
        (1..4).each do |quarter|
          Snapshot.generate_snapshot(company, user, nil, year, quarter)
        end
      end
    end
  end

  def snap_weighted_pipeline
    forecast = ForecastMember.new(user, time_period.start_date, time_period.end_date)
    self.weighted_pipeline = forecast.weighted_pipeline
  end

  def snap_revenue
    forecast = ForecastMember.new(user, time_period.start_date, time_period.end_date)
    self.revenue = forecast.revenue
  end

  def set_dates
    self.start_date ||= self.time_period.try(:start_date)
    self.end_date ||= self.time_period.try(:end_date)
  end
end
