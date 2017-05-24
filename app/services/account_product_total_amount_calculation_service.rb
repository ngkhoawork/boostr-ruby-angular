class AccountProductTotalAmountCalculationService < BaseService

  def perform
    calculated_amounts
  end

  private

  def calculated_amounts
    deal_product_budgets(start_date: time_dimension.start_date, end_date: time_dimension.end_date).map(&:attributes)
  end

  def deal_product_budgets(options = {})
    @deal_product_budgets ||= DealProductBudget.joins(deal_product: [deal: :stage] )
                                               .where(conditions,
                                                      client_id: client.id,
                                                      company_id: client.company_id,
                                                      start_date: options[:start_date],
                                                      end_date: options[:end_date])
                                               .select('sum(deal_product_budgets.budget) * stages.probability / 100 as weighted_budget,
                                                        sum(deal_product_budgets.budget) as unweighted_budget,
                                                        deal_products.product_id as product_id')
                                               .group('deal_products.product_id, stages.probability')
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.all
  end

  def conditions
    'deals.advertiser_id = :client_id
     OR deals.agency_id = :client_id
     AND deals.company_id = :company_id
     AND deal_products.open IS TRUE
     AND deal_product_budgets.end_date >= :start_date
     AND deal_product_budgets.start_date <= :end_date'
  end

end