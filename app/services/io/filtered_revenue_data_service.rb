class Io::FilteredRevenueDataService
  def initialize(io, start_date, end_date, member_ids, product_ids)
    @io           = io
    @company      = io.company
    @member_ids   = member_ids
    @product_ids  = product_ids
    @start_date   = start_date
    @end_date     = end_date
  end

  def perform
    partial_amounts
  end

  private

  attr_reader :io,
              :company,
              :member_ids,
              :product_ids,
              :start_date,
              :end_date

  def content_fees
    @_content_fees ||= io.content_fees.inject([]) do |result, content_fee|
      if product_ids.nil? || product_ids.include?(content_fee.product_id)
        result << content_fee
      end
      result
    end
  end

  def costs
    @_costs ||= io.costs.inject([]) do |result, cost|
      if product_ids.nil? || product_ids.include?(cost.product_id)
        result << cost
      end
      result
    end
  end

  def display_line_items
    @_display_line_items ||= io.display_line_items.inject([]) do |result, display_line_item|
      if product_ids.nil? || product_ids.include?(display_line_item.product_id)
        result << display_line_item
      end
      result
    end
  end

  def io_users
    @_io_users ||= io.io_members
      .select{ |io_member| member_ids.include?(io_member.user_id) }
  end

  def partial_amounts
    @_partial_amounts ||= [content_fee_partial_amounts, display_partial_amounts, cost_partial_amounts]
      .inject([0, 0]) do |total, item|
        puts "========"
        puts item.to_json
        total[0] += item[0]
        total[1] += item[1]
        total
      end
  end

  def content_fee_partial_amounts
    @_content_fee_partial_amounts ||= io_users.inject([0, 0]) do |total, member|
      item_data = content_fees.inject([0, 0]) do |item_total, item|
        item_data = item.content_fee_product_budgets.each do |budget|
          share = member.share
          if (start_date <= budget.end_date && end_date >= budget.start_date)
            sum_content_fee_budget_data(item_total, item, budget, member)
          end
        end
        item_total
      end
      total[0] += item_data[0] if total[0] == 0
      total[1] += item_data[1]
      total
    end
  end

  def cost_partial_amounts
    @_cost_partial_amounts ||= if company.enable_net_forecasting
      io_users.inject([0, 0]) do |total, member|
        item_data = costs.inject([0, 0]) do |item_total, item|
          item_data = item.cost_monthly_amounts.each do |budget|
            share = member.share
            if (start_date <= budget.end_date && end_date >= budget.start_date)
              deduct_cost_budget_data(item_total, item, budget, member)
            end
          end
          item_total
        end
        total[0] += item_data[0] if total[0] == 0
        total[1] += item_data[1]
        total
      end
    else
      [0, 0]
    end
  end

  def display_partial_amounts
    @_display_partial_amounts ||= io_users.inject([0, 0]) do |total, member|
      item_data = display_line_items.inject([0, 0]) do |item_total, item|
        share = member.share
        budget_data = item.display_line_item_budgets.inject([0, 0, 0, 0]) do |budget_total, budget|
          if (start_date <= budget.end_date && end_date >= budget.start_date)
            sum_display_budget_data(budget_total, item, budget, member)
          end
          budget_total
        end
        if (start_date <= item.end_date && end_date >= item.start_date)
          in_period_days = period_days(item, nil)
          in_period_effective_days = period_effective_days(item, nil, member)
          item_total[0] += budget_data[0] + item.ave_run_rate * (in_period_days - budget_data[2])
          item_total[1] += budget_data[1] + item.ave_run_rate * (in_period_effective_days - budget_data[3]) * share / 100
        end
        item_total
      end
      total[0] += item_data[0] if total[0] == 0
      total[1] += item_data[1]
      total
    end
  end

  def sum_content_fee_budget_data(total, item, budget, member)
    share = member.share
    in_period_days = period_days(io, budget)
    in_period_effective_days = period_effective_days(io, budget, member)

    total[0] += budget.corrected_daily_budget(start_date, end_date) * in_period_days
    total[1] += budget.corrected_daily_budget(start_date, end_date) * in_period_effective_days * share / 100
  end

  def deduct_cost_budget_data(total, item, budget, member)
    share = member.share
    in_period_days = period_days(io, budget)
    in_period_effective_days = period_effective_days(io, budget, member)

    total[0] -= budget.corrected_daily_budget(start_date, end_date) * in_period_days
    total[1] -= budget.corrected_daily_budget(start_date, end_date) * in_period_effective_days * share / 100
  end

  def sum_display_budget_data(total, item, budget, member)
    share = member.share
    in_period_days = period_days(item, budget)
    in_period_effective_days = period_effective_days(item, budget, member)
    total[0] += budget.daily_budget * in_period_days
    total[1] += budget.daily_budget * in_period_effective_days / 100 * share
    total[2] += in_period_days
    total[3] += in_period_effective_days
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
