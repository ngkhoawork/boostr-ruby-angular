class Snapshot < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  before_create :snap_weighted_pipeline
  before_create :snap_revenue

  scope :two_recent_for_time_period, -> (time_period) { where(time_period: time_period).order('created_at DESC').limit(2) }

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
    forecast = ForecastMember.new(user, time_period)
    self.weighted_pipeline = forecast.weighted_pipeline
  end

  def snap_revenue
    forecast = ForecastMember.new(user, time_period)
    self.revenue = forecast.revenue
  end
end
