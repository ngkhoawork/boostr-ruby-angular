class ConvertCurrency
  def self.call(exchange_rate, product_budget_params)
    return product_budget_params if exchange_rate == nil
    if product_budget_params[:budget_loc]
      product_budget_params[:budget] = (product_budget_params[:budget_loc].to_f / exchange_rate).round(2)
    end

    product_budget_params[:deal_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = (monthly_budget[:budget_loc].to_f / exchange_rate).round(2)
      end
    end if product_budget_params[:deal_product_budgets_attributes]

    product_budget_params[:content_fee_product_budgets_attributes].each do |monthly_budget|
      if monthly_budget[:budget_loc]
        monthly_budget[:budget] = (monthly_budget[:budget_loc].to_f / exchange_rate).round(2)
      end
    end if product_budget_params[:content_fee_product_budgets_attributes]

    product_budget_params
  end
end
