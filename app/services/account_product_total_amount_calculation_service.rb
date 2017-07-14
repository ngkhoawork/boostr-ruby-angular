class AccountProductTotalAmountCalculationService < BaseService

  def perform
    calculated_amounts
  end

  private

  def calculated_amounts
    deal_product_budgets.map(&:attributes)
  end

  def deal_product_budgets
    @deal_product_budgets ||= DealProductBudget.joins(deal_product: [deal: :stage] )
                                               .where(conditions,
                                                      account_id: account_id,
                                                      company_id: company_id,
                                                      start_date: date_range[:start_date],
                                                      end_date: date_range[:end_date])
                                               .select('sum(deal_product_budgets.budget) * stages.probability / 100 as weighted_budget,
                                                        sum(deal_product_budgets.budget) as unweighted_budget,
                                                        deal_products.product_id as product_id')
                                               .group('deal_products.product_id, stages.probability')
  end

  def conditions
    'deals.advertiser_id = :account_id
     OR deals.agency_id = :account_id
     AND deals.company_id = :company_id
     AND deal_products.open IS TRUE
     AND deal_product_budgets.end_date >= :start_date
     AND deal_product_budgets.start_date <= :end_date'
  end

end