class Deal::FilteredPipelineDataService
  def initialize(deal, start_date, end_date, member_ids, product_ids, is_net_forecast = false)
    @deal             = deal
    @member_ids       = member_ids
    @product_ids      = product_ids
    @start_date       = start_date
    @end_date         = end_date
    @is_net_forecast  = is_net_forecast
  end

  def perform
    partial_amounts
  end

  private

  attr_reader :deal,
              :member_ids,
              :product_ids,
              :start_date,
              :end_date,
              :is_net_forecast

  def deal_products
    @_deal_products ||= deal.deal_products.inject([]) do |result, deal_product|
      if deal_product.open == true && (product_ids.nil? || product_ids.include?(deal_product.product_id))
        result << deal_product
      end
      result
    end
  end

  def deal_users
    @_deal_users ||= deal.deal_members
      .select{ |deal_member| member_ids.nil? || member_ids.include?(deal_member.user_id) }
  end

  def partial_amounts
    @_partial_amounts ||= deal_users.inject([0, 0, init_months, init_quarters]) do |total, member|
      months = init_months
      quarters = init_quarters
      item_data = deal_products.inject([0, 0]) do |item_total, item|
        budget_data = deal_product_budgets(item, member)
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

  def deal_product_budgets(deal_product, deal_member)
    share = deal_member.share
    product = deal_product.product

    deal_product.deal_product_budgets.inject([0, 0]) do |sum, deal_product_budget|
      if end_date >= deal_product_budget.start_date && start_date <= deal_product_budget.end_date
        budget_data = deal_product_monthly_budgets(deal_product_budget, product, share)
        sum[0] += budget_data[0]
        sum[1] += budget_data[1]
      end
      sum
    end
  end

  def deal_product_monthly_budgets(deal_product_budget, product, share)
    index = deal_product_budget.start_date.month
    from = [start_date, deal_product_budget.start_date].max
    to = [end_date, deal_product_budget.end_date].min
    num_days = [(to.to_date - from.to_date) + 1, 0].max

    in_period_amt = deal_product_budget.daily_budget.to_f * num_days
    in_period_amt = in_period_amt * product.margin / 100 if is_net_forecast
    split_in_period_amt = in_period_amt * share / 100

    months[index - 1] += split_in_period_amt
    quarters[(index - 1) / 3] += split_in_period_amt

    [in_period_amt, split_in_period_amt]
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
end
