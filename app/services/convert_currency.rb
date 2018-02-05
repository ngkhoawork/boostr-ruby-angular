class ConvertCurrency
  def self.call(exchange_rate, product_budget_params)
    return product_budget_params if exchange_rate == nil
    if product_budget_params[:budget_loc]
      product_budget_params[:budget] = (product_budget_params[:budget_loc].to_f / exchange_rate).round(2)
    end

    if product_budget_params[:total_budget_loc]
      product_budget_params[:total_budget] = (product_budget_params[:total_budget_loc].to_f / exchange_rate).round(2).to_s
    end

    sum_of_monthly_budgets = 0.0
    sum_of_monthly_budgets_loc = 0.0

    product_budget_params[:deal_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = (monthly_budget[:budget_loc].to_f / exchange_rate).round(2)
        sum_of_monthly_budgets += monthly_budget[:budget]
        sum_of_monthly_budgets_loc += monthly_budget[:budget_loc].to_f
      end
    end if product_budget_params[:deal_product_budgets_attributes]

    product_budget_params[:content_fee_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = (monthly_budget[:budget_loc].to_f / exchange_rate).round(2)
        sum_of_monthly_budgets += monthly_budget[:budget]
        sum_of_monthly_budgets_loc += monthly_budget[:budget_loc].to_f
      end
    end if product_budget_params[:content_fee_product_budgets_attributes]

    product_budget_params[:cost_monthly_amounts_attributes].each do |monthly_amount|
      if monthly_amount[:budget_loc]
        monthly_amount[:budget] = (monthly_amount[:budget_loc].to_f / exchange_rate).round(2)
        sum_of_monthly_budgets += monthly_amount[:budget]
        sum_of_monthly_budgets_loc += monthly_amount[:budget_loc].to_f
      end
    end if product_budget_params[:cost_monthly_amounts_attributes]

    if sum_of_monthly_budgets_loc == product_budget_params[:budget_loc]
      product_budget_params[:budget] = sum_of_monthly_budgets
    end

    product_budget_params
  end
end
