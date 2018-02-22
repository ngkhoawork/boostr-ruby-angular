class Pmp::FilteredRevenueDataService
  def initialize(pmp, start_date, end_date, member_ids, product_ids)
    @pmp          = pmp
    @member_ids   = member_ids
    @product_ids  = product_ids
    @start_date   = start_date
    @end_date     = end_date
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
    @_pmp_items ||= pmp.pmp_items.inject([]) do |result, pmp_item|
      result << pmp_item if product_ids.nil? || product_ids.include?(pmp_item.product_id)
      result
    end
  end

  def pmp_users
    @_pmp_users ||= pmp.pmp_members
      .select{ |pmp_member| member_ids.nil? || member_ids.include?(pmp_member.user_id) }
  end

  def partial_amounts
    @_partial_amounts ||= pmp_users.inject([0, 0, init_months, init_quarters]) do |total, member|
      months = init_months
      quarters = init_quarters
      item_data = pmp_items.inject([0, 0]) do |item_total, item|
        budget_data = pmp_item_budgets(item, member)
        item_total[0] += budget_data[0]
        item_total[1] += budget_data[1]
        item_total
      end
      total[0] += item_data[0] if total[0] == 0
      total[1] += item_data[1]
      total[2] = months if total[2].nil?
      total[3] = quarters if total[3].nil?
      total
    end
  end

  def pmp_item_budgets(pmp_item, pmp_member)
    total = [0, 0]
    share = pmp_member.share
    pmp_actuals = pmp_item.pmp_item_daily_actuals

    actual_start_date = pmp_actuals.first&.date || pmp_item.start_date
    actual_end_date = pmp_actuals.last&.date || pmp_item.start_date

    (start_date.mon..end_date.mon).to_a.inject([0, 0]) do |monthly_total, index|
      month = index.to_s
      if index < 10
        month = '0' + index.to_s
      end
      first_date = Date.parse("#{year}#{month}01")
      range_start_date = [
        start_date,
        pmp.start_date,
        pmp_member.from_date,
        first_date,
      ].max
      range_end_date = [
        end_date,
        pmp.end_date,
        pmp_member.to_date,
        first_date.end_of_month,
      ].min

      if range_start_date <= actual_end_date && range_end_date >= actual_start_date
        monthly_data = pmp_item_actuals_amount(pmp_item, range_start_date, range_end_date, share, index)
        monthly_total[0] += monthly_data[0]
        monthly_total[1] += monthly_data[1]
      end

      if product_ids.nil?
        amount = pmp_item_projection_amount(pmp_item, range_start_date, range_end_date, actual_end_date, share, index)
        monthly_total[0] += amount
        monthly_total[1] += amount * share / 100.0
      end
      monthly_total
    end
  end

  def pmp_item_actuals_amount(pmp_item, range_start_date, range_end_date, share, index)
    pmp_item.pmp_item_daily_actuals.inject([0, 0]) do |actual_total, pmp_actual|
      if pmp_actual.date >= range_start_date &&
          pmp_actual.date <= range_end_date
        actual_total[0] += pmp_actual.revenue.to_f
        actual_total[1] += pmp_actual.revenue.to_f * share / 100.0
        months[index - 1] += pmp_actual.revenue.to_f
        quarters[(index - 1) / 3] += pmp_actual.revenue.to_f
      end
      actual_total
    end
  end

  def pmp_item_projection_amount(pmp_item, range_start_date, range_end_date, actual_end_date, share, index)
    run_rate = pmp_item_run_rate(pmp_item)
    remaining_days = [(range_end_date - [range_start_date - 1.days, actual_end_date].max).to_i, 0].max
    amount = run_rate.to_f * remaining_days
    split_amount = run_rate.to_f * remaining_days * share / 100.0
    months[index - 1] += amount
    quarters[(index - 1) / 3] += amount
    amount
  end

  def year
    @_year ||= start_date.year
  end

  def start_month
    @_start_month ||= start_date.month
  end

  def end_month
    @_end_month ||= end_date.month
  end

  def init_quarters
    return @_init_quarters if defined?(@_init_quarters)
    @_init_quarters = Array.new(4, nil)
    for i in ((start_month - 1) / 3)..((end_month - 1) / 3)
      @_init_quarters[i] = 0
    end
    @_init_quarters
  end

  def quarters
    @_quarters ||= init_quarters
  end

  def init_months
    return @_init_months if defined?(@_init_months)
    @_init_months = Array.new(12, nil)
    for i in start_month..end_month
      @_init_months[i - 1] = 0
    end
    @_init_months
  end

  def months
    @_months ||= init_months
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
end
