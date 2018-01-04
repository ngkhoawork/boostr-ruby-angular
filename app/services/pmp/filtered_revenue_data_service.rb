class Pmp::FilteredRevenueDataService
  def initialize(pmp, start_date, end_date, member_ids, product_ids)
    @pmp          = pmp
    @member_ids   = member_ids
    @product_ids  = product_ids
    @start_date   = start_date
    @end_date     = end_date

    puts "==========product_ids"
    puts product_ids.nil?
  end

  def perform
    partial_amounts
  end

  private

  attr_reader :pmp,
              :member_ids,
              :product_ids,
              :start_date,
              :end_date

  def pmp_items
    @_pmp_items ||= pmp.pmp_items
  end

  def pmp_users
    @_pmp_users ||= pmp.pmp_members
      .select{ |pmp_member| member_ids.include?(pmp_member.user_id) }
  end

  def partial_amounts
    @_partial_amounts ||= pmp_users.inject([0, 0]) do |total, member|
      item_data = pmp_items.inject([0, 0]) do |item_total, item|
        budget_data = pmp_item_budgets(item, member)
        item_total[0] += budget_data[0]
        item_total[1] += budget_data[1]
        item_total
      end
      total[0] += item_data[0] if total[0] == 0
      total[1] += item_data[1]
      total
    end
  end

  def pmp_item_budgets(pmp_item, pmp_member)
    total = [0, 0]
    share = pmp_member.share
    pmp_actuals = pmp_item.pmp_item_daily_actuals
    actual_start_date = pmp_actuals.first.date
    actual_end_date = pmp_actuals.last.date
    run_rate = pmp_item_run_rate(pmp_item)

    range_start_date = [
      start_date,
      pmp.start_date,
      pmp_member.from_date,
    ].max
    range_end_date = [
      end_date,
      pmp.end_date,
      pmp_member.to_date,
    ].min
    if range_start_date <= actual_end_date && range_end_date >= actual_start_date
      total = pmp_actuals.inject([0, 0]) do |actual_total, pmp_actual|
        if pmp_actual.date >= range_start_date &&
            pmp_actual.date <= range_end_date &&
            (product_ids.nil? || product_ids.include?(pmp_actual.product_id))
          actual_total[0] += pmp_actual.revenue.to_f
          actual_total[1] += pmp_actual.revenue.to_f * share / 100.0
        end
        actual_total
      end
    end

    if product_ids.nil?
      remaining_days = [(range_end_date - [range_start_date - 1.days, actual_end_date].max).to_i, 0].max
      amount = run_rate.to_f * remaining_days
      split_amount = run_rate.to_f * remaining_days * share / 100.0
      total[0] += amount
      total[1] += amount * share / 100.0
    end
    total
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

  def period_effective_days(object, budget, member)
    to_date = [end_date, object.end_date, (budget ? budget.end_date : end_date), member.to_date].min
    from_date = [start_date, object.start_date, (budget ? budget.start_date : start_date), member.from_date].max
    in_period_effective_days = [to_date - from_date + 1, 0].max
  end
  
  def period_days(object, budget)
    to_date = [end_date, object.end_date, (budget ? budget.end_date : end_date)].min
    from_date = [start_date, object.start_date, (budget ? budget.start_date : start_date)].max
    in_period_days = [to_date - from_date + 1, 0].max
  end
end
