class Io::FilteredRevenueDataService
  def initialize(io, start_date, end_date, member_ids, product_ids)
    @io           = io
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

  def total_share
    @_total_share ||= io_users.inject(0) do |result, io_user|
        io_user.share
      end
  end

  def partial_amounts
    @_partial_amounts ||= [content_fee_partial_amounts, display_partial_amounts]
      .inject([0, 0]) do |result, item|
        result[0] += item[0]
        result[1] += item[1]
        result
      end
  end

  def content_fee_partial_amounts
    @_content_fee_partial_amounts ||= content_fees.inject([0, 0]) do |result, item|
      item_data = item.content_fee_product_budgets.each do |budget|
        user_data = io_users.each do |member|
          share = member.share
          if (start_date <= budget.end_date && end_date >= budget.start_date)
            sum_content_fee_budget_data(result, item, budget, member)
          end
        end
      end
      result
    end
  end

  def display_partial_amounts
    @_display_partial_amounts ||= display_line_items.inject([0, 0]) do |result, item|
      io_users.each do |member|
        share = member.share
        budget_data = item.display_line_item_budgets.inject([0, 0, 0, 0]) do |res, budget|
          if (start_date <= budget.end_date && end_date >= budget.start_date)
            sum_display_budget_data(res, item, budget, member)
          end
          res
        end
        if (start_date <= item.end_date && end_date >= item.start_date)
          in_period_days = period_days(item, nil)
          in_period_effective_days = period_effective_days(item, nil, member)
          result[0] += budget_data[0] + item.ave_run_rate * (in_period_days - budget_data[2])
          result[1] += budget_data[1] + item.ave_run_rate * (in_period_effective_days - budget_data[3]) * share / 100
        end
      end
      result
    end
  end

  def sum_content_fee_budget_data(res, item, budget, member)
    share = member.share
    in_period_days = period_days(io, budget)
    in_period_effective_days = period_effective_days(io, budget, member)

    res[0] += budget.corrected_daily_budget(start_date, end_date) * in_period_days
    res[1] += budget.corrected_daily_budget(start_date, end_date) * in_period_effective_days * share / 100
  end

  def sum_display_budget_data(res, item, budget, member)
    share = member.share
    in_period_days = period_days(item, budget)
    in_period_effective_days = period_effective_days(item, budget, member)
    res[0] += budget.daily_budget * in_period_days
    res[1] += budget.daily_budget * in_period_effective_days / 100 * share
    res[2] += in_period_days
    res[3] += in_period_effective_days
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
