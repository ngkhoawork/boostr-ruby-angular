class Snapshot < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  before_create :snap_weighted_pipeline
  before_create :snap_revenue

  before_save :set_dates

  scope :two_recent_for_time_period, -> (start_date, end_date) { where('snapshots.start_date <= ? AND snapshots.end_date >= ?', end_date, start_date).order('created_at DESC').limit(2) }

  validates :company, :user, :time_period, presence: true

  def self.generate_snapshot(company, user, time_period)
    Snapshot.create(company: company, user: user, time_period: time_period)
  end

  def self.generate_snapshots(company)
    company.users.each do |user|
      company.time_periods.each do |time_period|
        Snapshot.generate_snapshot(company, user, time_period)
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
