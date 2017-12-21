class Forecast::PmpRevenueCalcService
  def initialize(time_period, user, product)
    @time_period = time_period
    @forecast_time_dimension = ForecastTimeDimension.find_by_id(time_period.id)
    @start_date = time_period.start_date
    @end_date = time_period.end_date
    @user = user
    @product = product
  end

  def perform
    return if !@forecast_time_dimension
    monthly_value = months.inject({}) do |result, month_row|
      result[month_row[:start_date].strftime('%b-%y')] = 0
      result
    end
    total = pmps.inject(0) do |pmp_total, pmp|
      pmp_member = pmp_user_member(pmp)
      pmp_total += pmp.pmp_items.inject(0) do |total, pmp_item|
        total += pmp_item_budgets(monthly_value, pmp_item, pmp_member, pmp)
      end
      pmp_total
    end
    forecast_pmp_revenue_fact.amount = total
    forecast_pmp_revenue_fact.monthly_amount = monthly_value
    forecast_pmp_revenue_fact.save
  end

  private

  attr_reader :time_period,
              :forecast_time_dimension,
              :start_date,
              :end_date,
              :user,
              :product

  def forecast_pmp_revenue_fact
    @_forecast_pmp_revenue_fact ||= ForecastPmpRevenueFact.find_or_initialize_by(
      forecast_time_dimension_id: forecast_time_dimension.id,
      user_dimension_id: user.id,
      product_dimension_id: product.id
    )
  end

  def pmp_item_budgets(monthly_value, pmp_item, pmp_member, pmp)
    share = pmp_member.share
    pmp_actuals = pmp_item.pmp_item_daily_actuals
    actual_start_date = pmp_actuals.first.date
    actual_end_date = pmp_actuals.last.date
    run_rate = pmp_item_run_rate(pmp_item)

    months.inject(0) do |total, month_row|
      month_name = month_row[:start_date].strftime('%b-%y')
      range_start_date = [
        start_date,
        pmp.start_date,
        pmp_member.from_date,
        month_row[:start_date]
      ].max
      range_end_date = [
        end_date,
        pmp.end_date,
        pmp_member.to_date,
        month_row[:end_date]
      ].min
      if range_start_date <= actual_end_date && range_end_date >= actual_start_date
        total += pmp_actuals.inject(0) do |actual_total, pmp_actual|
          if pmp_actual.date >= range_start_date &&
              pmp_actual.date <= range_end_date &&
              (product.nil? || product.id == pmp_actual.product_id)

            split_amount = pmp_actual.revenue.to_f * share / 100.0
            monthly_value[month_name] ||= 0
            monthly_value[month_name] += split_amount
            actual_total += split_amount
          end
          actual_total
        end
      end

      if product.nil?
        remaining_days = [(range_end_date - [range_start_date - 1.days, actual_end_date].max).to_i, 0].max
        split_amount = run_rate.to_f * remaining_days * share / 100.0
        monthly_value[month_name] += split_amount
        total += split_amount
      end
      total
    end
  end

  def pmp_item_run_rate(pmp_item)
    case pmp_item.pmp_type 
      when 'non_guaranteed'
        if pmp_item.run_rate_30_days
          pmp_item.run_rate_30_days
        elsif pmp_item.run_rate_7_days
          pmp_item.run_rate_7_days
        else
          0
        end
      when 'guaranteed'
        pmp_item.pmp_item_daily_actuals.sum(:revenue) / pmp_item.pmp_item_daily_actuals.count
      else
        0
    end
  end

  def pmps
    @_pmps ||= user.pmps
      .for_time_period(@start_date, @end_date)
      .by_user(user)
      .includes({
        pmp_items: {
          pmp_item_daily_actuals: {}
        },
      })
  end

  def pmp_user_member(pmp)
    pmp.pmp_members.inject(nil) do |member, pmp_member|
      if pmp_member.user_id == user.id
        member = pmp_member
      end
      member
    end
  end

  def months
    @months ||= (@start_date.to_date..@end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
  end
end
