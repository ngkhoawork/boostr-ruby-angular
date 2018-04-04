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
        if product.nil? || product&.id == pmp_item.product_id
          total += pmp_item_budgets(monthly_value, pmp_item, pmp_member, pmp)
        end
        total
      end
      pmp_total
    end

    create_forecast_pmp_revenue_fact(total, monthly_value)
  end

  def create_forecast_pmp_revenue_fact(total, monthly_value)
    if total > 0
      forecast_pmp_revenue_fact.update(
        amount: total,
        monthly_amount: monthly_value
      )
    elsif forecast_pmp_revenue_fact.id.present?
      forecast_pmp_revenue_fact.destroy
    end
  end

  private

  attr_reader :time_period,
              :forecast_time_dimension,
              :start_date,
              :end_date,
              :user,
              :product

  def forecast_pmp_revenue_fact
    ForecastPmpRevenueFact.find_or_initialize_by(
      forecast_time_dimension_id: forecast_time_dimension.id,
      user_dimension_id: user.id,
      product_dimension_id: product&.id
    )
  end

  def pmp_item_budgets(monthly_value, pmp_item, pmp_member, pmp)
    share = pmp_member.share
    pmp_actuals = pmp_item.pmp_item_daily_actuals

    actual_start_date = pmp_actuals.first&.date || pmp_item.start_date
    actual_end_date = pmp_actuals.last&.date || pmp_item.start_date

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

      is_in_range = range_start_date <= actual_end_date && range_end_date >= actual_start_date

      if product&.id == pmp_item.product_id && is_in_range
        total += pmp_item_actuals_amount(monthly_value, pmp_item, range_start_date, range_end_date, share, month_name)
      end

      if product.nil?
        total += pmp_item_projection_amount(monthly_value, pmp_item, range_start_date, range_end_date, actual_end_date, share, month_name)
      end
      total
    end
  end

  def pmp_item_actuals_amount(monthly_value, pmp_item, range_start_date, range_end_date, share, month_name)
    pmp_item.pmp_item_daily_actuals.inject(0) do |actual_total, pmp_actual|
      if pmp_actual.date >= range_start_date &&
          pmp_actual.date <= range_end_date
        split_amount = pmp_actual.revenue.to_f * share / 100.0
        monthly_value[month_name] ||= 0
        monthly_value[month_name] += split_amount
        actual_total += split_amount
      end
      actual_total
    end
  end

  def pmp_item_projection_amount(monthly_value, pmp_item, range_start_date, range_end_date, actual_end_date, share, month_name)
    run_rate = pmp_item_run_rate(pmp_item)
    remaining_days = [(range_end_date - [range_start_date - 1.days, actual_end_date].max).to_i, 0].max
    split_amount = run_rate.to_f * remaining_days * share / 100.0
    monthly_value[month_name] += split_amount
    split_amount
  end

  def pmp_item_run_rate(pmp_item)
    case pmp_item.pmp_type 
      when 'guaranteed'
        actual_end_date = pmp_item.pmp_item_daily_actuals.last&.date || pmp_item.start_date
        remaining_days = [pmp_item.end_date - actual_end_date, 0].max
        remaining_budget = pmp_item.budget - pmp_item.pmp_item_daily_actuals.sum(:revenue)
        if remaining_days == 0
          0
        else
          remaining_budget / remaining_days
        end
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
      member = pmp_member if pmp_member.user_id == user.id
      member
    end
  end

  def months
    @months ||= (@start_date.to_date..@end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
  end
end
