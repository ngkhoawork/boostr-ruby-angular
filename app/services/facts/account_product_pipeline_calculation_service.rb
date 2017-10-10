class Facts::AccountProductPipelineCalculationService < BaseService
  attr_reader :calculated_pipelines

  def self.perform(params)
    self.new(params).tap do |instance|
      instance.calculate_pipelines
    end
  end

  def calculate_pipelines
    @calculated_pipelines = [calculated_advertiser_amounts, calculated_agency_amounts].inject(&:union)
  end

  private

  def calculated_advertiser_amounts
    DealProductBudget.select('sum(ceil(weighted_budget::DOUBLE PRECISION)) as weighted_amount,
                              sum(ceil(unweighted_budget::DOUBLE PRECISION)) as unweighted_amount,
                              advertiser_id as account_dimension_id,
                              company_id,
                              product_id')
                     .where('advertiser_id IS NOT NULL')
                     .from(pipelines)
                     .group('account_dimension_id, product_id, company_id')
  end

  def calculated_agency_amounts
    DealProductBudget.select('sum(ceil(weighted_budget::DOUBLE PRECISION)) as weighted_amount,
                              sum(ceil(unweighted_budget::DOUBLE PRECISION)) as unweighted_amount,
                              agency_id as account_dimension_id,
                              company_id,
                              product_id')
                     .where('agency_id IS NOT NULL')
                     .from(pipelines)
                     .group('account_dimension_id, product_id, company_id')
  end

  def pipelines
    deal_product_budgets
        .group('deals.advertiser_id, deals.agency_id, stages.probability, deals.company_id, products.id')
        .select('sum(deal_product_budgets.budget::DOUBLE PRECISION) * stages.probability / 100 as weighted_budget,
                 sum(deal_product_budgets.budget::DOUBLE PRECISION) as unweighted_budget,
                 deals.advertiser_id as advertiser_id,
                 deals.agency_id as agency_id,
                 deals.company_id as company_id,
                 products.id as product_id')
  end

  def deal_product_budgets
    DealProductBudget.joins(deal_product: [:product, deal: :stage])
        .where(conditions,
               company_id: company_id,
               start_date: start_date,
               end_date: end_date)
  end

  def conditions
    'deals.company_id = :company_id
     AND deal_products.open IS TRUE
     AND stages.open IS TRUE
     AND stages.probability != 100
     AND stages.probability != 0
     AND deal_product_budgets.end_date >= :start_date
     AND deal_product_budgets.start_date <= :end_date'
  end
end