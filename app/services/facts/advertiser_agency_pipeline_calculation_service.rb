class Facts::AdvertiserAgencyPipelineCalculationService < BaseService
  attr_reader :calculated_pipelines

  def self.perform(params)
    self.new(params).tap do |instance|
      instance.calculate_pipelines
    end
  end

  def calculate_pipelines
    @calculated_pipelines = calculated_amounts
  end

  private

  def calculated_amounts
    DealProductBudget.find_by_sql(sql)
  end

  def sql
    "SELECT sum(ceil(pipelines.weighted_budget::DOUBLE PRECISION)) as weighted_amount,
            sum(ceil(pipelines.unweighted_budget::DOUBLE PRECISION)) as unweighted_amount,
            pipelines.advertiser_id,
            pipelines.agency_id,
            pipelines.company_id
     FROM (#{pipelines.to_sql}) AS pipelines
     GROUP BY pipelines.advertiser_id, pipelines.agency_id, pipelines.company_id"
  end

  def pipelines
    deal_product_budgets
        .group('deals.advertiser_id, deals.agency_id, stages.probability, deals.company_id')
        .select('sum(deal_product_budgets.budget::DOUBLE PRECISION) * stages.probability / 100 as weighted_budget,
                 sum(deal_product_budgets.budget::DOUBLE PRECISION) as unweighted_budget,
                 deals.advertiser_id as advertiser_id,
                 deals.agency_id as agency_id,
                 deals.company_id as company_id')
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