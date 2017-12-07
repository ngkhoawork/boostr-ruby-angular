class PublisherDailyRevenueGraphService
  def initialize(publisher)
    @publisher = publisher
  end

  def perform
    return [] if daily_actuals.empty?

    generate_dates.map do |date|
      {
        date: date,
        revenue: daily_revenue_by_date(date)
      }
    end
  end

  private

  def daily_actuals
    @daily_actuals ||= @publisher.daily_actuals.order(:date).to_a
  end

  def daily_revenue_by_date(date)
    daily_actual_by_date(date)&.total_revenue&.to_i || 0
  end

  def daily_actual_by_date(date)
    daily_actuals.detect { |daily_actual| daily_actual.date == date }
  end

  def generate_dates
    (start_date..end_date)
  end

  def start_date
    daily_actuals[0].date
  end

  def end_date
    daily_actuals[-1].date
  end
end
