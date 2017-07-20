class AccountProductTotalAmountCalculationService < BaseService

  def perform
    calculated_amounts
  end

  private

  def calculated_amounts
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def sql
    "SELECT sum(sums.weighted_budget) as weighted_budget, sum(sums.unweighted_budget) as unweighted_budget, sums.product_id
     FROM (#{deal_product_budgets.to_sql})
     AS sums GROUP BY sums.product_id"
  end

  def deal_product_budgets
    @deal_product_budgets ||= DealProductBudget.joins(deal_product: [:product, deal: :stage] )
                                               .joins('JOIN account_dimensions ON deals.advertiser_id = account_dimensions.id
                                                       OR deals.agency_id = account_dimensions.id')
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
    'account_dimensions.id = :account_id
     AND deals.company_id = :company_id
     AND deal_products.open IS TRUE
     AND stages.open IS TRUE
     AND stages.probability != 100
     AND stages.probability != 0
     AND deal_product_budgets.end_date >= :start_date
     AND deal_product_budgets.start_date <= :end_date'
  end

end