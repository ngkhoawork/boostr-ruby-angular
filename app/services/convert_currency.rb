class ConvertCurrency
  def self.call(exchange_rate, product_budget_params, exchange_rate_at_close=nil)
    return product_budget_params if exchange_rate == nil

    @sum_of_monthly_budgets = 0.0
    @sum_of_monthly_budgets_loc = 0.0

    set_deal_product_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    set_content_fee_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    set_cost_product_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    set_budget_params(exchange_rate, product_budget_params, exchange_rate_at_close)

    product_budget_params
  end

  def self.set_budget_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    if product_budget_params[:budget_loc]
      product_budget_params[:budget] = convert_to_usd(product_budget_params[:budget_loc], exchange_rate, exchange_rate_at_close)
    end
    if product_budget_params[:total_budget_loc]
      product_budget_params[:total_budget] = (product_budget_params[:total_budget_loc].to_f / exchange_rate).round(2).to_s
    end
    if @sum_of_monthly_budgets_loc == product_budget_params[:budget_loc]
      product_budget_params[:budget] = @sum_of_monthly_budgets
    end
  end

  def self.set_deal_product_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    product_budget_params[:deal_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = convert_to_usd(monthly_budget[:budget_loc], exchange_rate, exchange_rate_at_close)
        @sum_of_monthly_budgets += monthly_budget[:budget]
        @sum_of_monthly_budgets_loc += monthly_budget[:budget_loc].to_f
      end
    end if product_budget_params[:deal_product_budgets_attributes]
  end

  def self.set_content_fee_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    product_budget_params[:content_fee_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = convert_to_usd(monthly_budget[:budget_loc], exchange_rate, exchange_rate_at_close)
        @sum_of_monthly_budgets += monthly_budget[:budget]
        @sum_of_monthly_budgets_loc += monthly_budget[:budget_loc].to_f
      end
    end if product_budget_params[:content_fee_product_budgets_attributes]
  end

  def self.set_cost_product_params(exchange_rate, product_budget_params, exchange_rate_at_close)
    product_budget_params[:cost_monthly_amounts_attributes].each do |monthly_amount|
      if monthly_amount[:budget_loc]
        monthly_amount[:budget] = convert_to_usd(monthly_amount[:budget_loc], exchange_rate, exchange_rate_at_close)
        @sum_of_monthly_budgets += monthly_amount[:budget]
        @sum_of_monthly_budgets_loc += monthly_amount[:budget_loc].to_f
      end
    end if product_budget_params[:cost_monthly_amounts_attributes]
  end

  private

  def self.convert_to_usd(value, exchange_rate, exchange_rate_at_close)
    if exchange_rate_at_close
      value.to_f * exchange_rate_at_close.to_f
    else
      value.to_f / exchange_rate.to_f
    end.round(2)
  end
end
