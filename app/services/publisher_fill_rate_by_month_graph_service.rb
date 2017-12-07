class PublisherFillRateByMonthGraphService
  def initialize(publisher)
    @publisher = publisher
  end

  def perform
    return [] if daily_actuals.empty?

    generate_dates_by_months.map do |date|
      graph_row = initialize_graph_row(date)

      daily_actual = daily_actual_by_year_month(date)

      if daily_actual
        month_unfilled_impressions = daily_actual.month_available_impressions - daily_actual.month_filled_impressions
        month_fill_rate = daily_actual.month_filled_impressions * 100 / daily_actual.month_available_impressions

        graph_row.merge!(
          {
            curr_symbol: daily_actual.curr_symbol,
            month_available_impressions: daily_actual.month_available_impressions,
            month_filled_impressions: daily_actual.month_filled_impressions,
            month_unfilled_impressions: month_unfilled_impressions,
            month_fill_rate: month_fill_rate
          }
        )
      end

      graph_row
    end
  end

  private

  def daily_actuals
    @daily_actuals ||=
      @publisher
        .daily_actuals
        .group("to_char(date, 'YYYY-MM')")
        .select(
          "MIN(date) AS date,
           MIN(currency_id) AS currency_id,
           SUM(available_impressions) AS month_available_impressions,
           SUM(filled_impressions) AS month_filled_impressions"
        )
        .order('date')
        .includes(:currency)
        .to_a
  end

  def daily_actual_by_year_month(date)
    daily_actuals.detect do |daily_actual|
      daily_actual.date.year == date.year && daily_actual.date.month == date.month
    end
  end

  def initialize_graph_row(date)
    {
      year_month: date.strftime('%Y-%m'),
      year: date.year,
      month: date.month,
      curr_symbol: 0,
      month_available_impressions: 0,
      month_filled_impressions: 0,
      month_unfilled_impressions: 0,
      month_fill_rate: 0
    }
  end

  def generate_dates_by_months
    (start_date..end_date).to_a.uniq { |date| [date.year, date.month]  }
  end

  def start_date
    daily_actuals[0].date
  end

  def end_date
    daily_actuals[-1].date
  end
end
