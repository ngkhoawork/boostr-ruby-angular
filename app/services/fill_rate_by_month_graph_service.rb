class FillRateByMonthGraphService
  def initialize(publisher)
    @publisher = publisher
  end

  def perform
    query_db.map do |daily_actual|
      month_unfilled_impressions = daily_actual.month_available_impressions - daily_actual.month_filled_impressions
      month_fill_rate = daily_actual.month_filled_impressions * 100 / daily_actual.month_available_impressions

      {
        year_month: daily_actual.year_month,
        curr_symbol: daily_actual.currency.curr_symbol,
        month_available_impressions: daily_actual.month_available_impressions,
        month_filled_impressions: daily_actual.month_filled_impressions,
        month_unfilled_impressions: month_unfilled_impressions,
        month_fill_rate: month_fill_rate
      }
    end
  end

  private

  def query_db
    @publisher
      .daily_actuals
      .group("to_char(date, 'YYYY-MM')")
      .select(
        "to_char(date, 'YYYY-MM') AS year_month,
         MIN(currency_id) AS currency_id,
         SUM(available_impressions) AS month_available_impressions,
         SUM(filled_impressions) AS month_filled_impressions"
      )
      .order('year_month')
      .includes(:currency)
  end
end
