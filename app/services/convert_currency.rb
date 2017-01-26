class ConvertCurrency
  def self.call(exchange_rate, product_budget_params)
    if product_budget_params[:budget_loc] && !product_budget_params[:budget]
      product_budget_params[:budget] = (product_budget_params[:budget_loc].to_f / exchange_rate).round(2)
    end

    product_budget_params[:deal_product_budgets_attributes].each do |dpb|
      if dpb[:budget_loc] && !dpb[:budget]
        dpb[:budget] = (dpb[:budget_loc].to_f / exchange_rate).round(2)
      end
    end
    product_budget_params
  end
end
