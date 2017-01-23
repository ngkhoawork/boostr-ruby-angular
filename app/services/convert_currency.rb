class ConvertCurrency
  def self.call(deal, deal_product_params)
    exchange_rate = deal.deal_exchange_rate

    if deal_product_params[:budget_loc] && !deal_product_params[:budget]
      deal_product_params[:budget] = deal_product_params[:budget_loc].to_f / exchange_rate
    end

    deal_product_params[:deal_product_budgets_attributes].each do |dpb|
      if dpb[:budget_loc] && !dpb[:budget]
        dpb[:budget] = dpb[:budget_loc].to_f / exchange_rate
      end
    end
    deal_product_params
  end
end
