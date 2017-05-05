class AccountProductTotalAmountCalculationService < BaseService
  attr_reader :calculated_amounts

  def perform
    calculate_amounts
  end

  def calculated_amounts
    @calculated_amounts ||= []
  end

  private

  def create_or_update_calculated_amount_item(time_dimension, options = {})
    found_element_index = find_amount_item_index(time_dimension.id)
    if found_element_index
      calculated_amounts[found_element_index].weighted_amount += options[:weighted_amount]
      calculated_amounts[found_element_index].unweighted_amount += options[:unweighted_amount]
    else
      new_elem = Hashie::Mash.new(weighted_amount: 0, unweighted_amount: 0)
      new_elem.time_dimension_id = time_dimension.id
      new_elem.weighted_amount += options[:weighted_amount]
      new_elem.unweighted_amount += options[:unweighted_amount]
      new_elem.product_id = options[:product_id]
      calculated_amounts << new_elem
    end
  end

  def find_amount_item_index(time_dimension_id)
    calculated_amounts.find_index {|el| el.time_dimension_id == time_dimension_id }
  end

  def calculate_amounts
    deal_product_budgets.each do |deal_product_budget|
      time_dimensions.each do |time_dimension|
        if time_dimension.start_date <= deal_product_budget.end_date && deal_product_budget.end_date >= deal_product_budget.start_date
          service = DealProductBudgetPipelineService.new(deal_product_budget: deal_product_budget)
          create_or_update_calculated_amount_item(time_dimension,
                                                  weighted_amount: service.weighted_amount,
                                                  unweighted_amount: service.unweighted_amount,
                                                  product_id: deal_product_budget.product_id)

        end
      end
    end
  end

  def deal_product_budgets
    @deal_product_budgets ||= DealProductBudget.joins(deal_product: [deal: :stage] )
                                               .where(conditions, client.id, client.id, client.company_id )
                                               .select('deal_product_budgets.*, stages.probability as probability, deal_products.product_id as product_id')
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.all
  end

  def conditions
    "deals.advertiser_id = ? OR deals.agency_id = ? AND deals.company_id = ? AND deal_products.open IS TRUE"
  end

end