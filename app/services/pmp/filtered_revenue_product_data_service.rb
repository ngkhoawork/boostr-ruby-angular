class Pmp::FilteredRevenueProductDataService
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
    @_pmp_items ||= pmp.pmp_items.select {|i| product_ids.nil? || product_ids.include?(i.product_id)}
  end

  def pmp_users
    @_pmp_users ||= pmp.pmp_members
      .select{ |pmp_member| member_ids.nil? || member_ids.include?(pmp_member.user_id) }
  end

  def partial_amounts
    @_partial_amounts ||= pmp_users.inject([0, 0, nil, nil]) do |total, member|
      item_data = pmp_items.inject([0, 0]) do |item_total, item|
        budget_data = pmp_item_budgets(item, member)
        item_total[0] += budget_data[0]
        item_total[1] += budget_data[1]
        item_total
      end
      total[0] += item_data[0] if total[0] == 0
      total[1] += item_data[1]
      total[2] = product_data if total[2].nil?
      total
    end
  end

  def pmp_item_budgets(pmp_item, pmp_member)
    total = [0, 0]
    share = pmp_member.share
    pmp_actuals = pmp_item.pmp_item_daily_actuals

    actual_start_date = pmp_actuals.minimum(:date) || pmp_item.start_date
    actual_end_date = pmp_actuals.maximum(:date) || pmp_item.start_date

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
      total = pmp_item_actuals_amount(pmp_item, range_start_date, range_end_date, share)
    end

    if product_ids.nil?
      projection_amount = pmp_item_projection_amount(pmp_item, range_start_date, range_end_date, actual_end_date, share)
      total[0] += projection_amount[0]
      total[1] += projection_amount[1]
    end
    
    total
  end

  def pmp_item_actuals_amount(pmp_item, range_start_date, range_end_date, share)
    item_product_id = pmp_item.product_id || 0
    pmp_item.pmp_item_daily_actuals.inject([0, 0]) do |actual_total, pmp_actual|
      if pmp_actual.date >= range_start_date && pmp_actual.date <= range_end_date
        actual_total[0] += pmp_actual.revenue.to_f
        actual_total[1] += pmp_actual.revenue.to_f * share / 100.0
        product_data[item_product_id] ||= {
          product_id: item_product_id,
          product: pmp_item.product,
          in_period_amt: 0,
          in_period_split_amt: 0,
        }
        product_data[item_product_id][:in_period_amt] += pmp_actual.revenue.to_f
        product_data[item_product_id][:in_period_split_amt] += pmp_actual.revenue.to_f * share / 100.0
      end
      actual_total
    end
  end

  def pmp_item_projection_amount(pmp_item, range_start_date, range_end_date, actual_end_date, share)
    run_rate = pmp_item_run_rate(pmp_item)
    remaining_days = [(range_end_date - [range_start_date - 1.days, actual_end_date].max).to_i, 0].max
    amount = run_rate.to_f * remaining_days
    split_amount = amount * share / 100.0
    product_data[0] ||= {
      product_id: nil,
      product: nil,
      in_period_amt: 0,
      in_period_split_amt: 0,
    }
    product_data[0][:in_period_amt] += amount
    product_data[0][:in_period_split_amt] += split_amount
    [amount, split_amount]
  end

  def product_data
    @_product_data ||= {}
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
