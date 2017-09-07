class Facts::AccountProductPipelineCalculationService < BaseService

  def calculate_products_pipeline
    calculated_amounts
  end

  def destroy_unused_records
    unused_records.delete_all
  end

  private

  def unused_records
    return existing_pipeline_facts unless calculated_product_amounts_ids.any?
    existing_pipeline_facts.where('product_dimension_id not in (:ids)', ids: calculated_product_amounts_ids)
  end

  def existing_pipeline_facts
    @existing_pipeline_facts ||= AccountProductPipelineFact.where('account_dimension_id = :account_id
                                                                   AND time_dimension_id = :time_dimension_id
                                                                   AND company_id = :company_id',
                                                                   account_id: account_id,
                                                                   time_dimension_id: time_dimension_id,
                                                                   company_id: company_id)
  end

  def calculated_product_amounts_ids
    @calculated_product_amounts_ids ||= deal_product_budgets.map(&:product_id)
  end

  def time_dimension_id
    TimeDimension.where(start_date: date_range[:start_date], end_date: date_range[:end_date]).pluck(:id)
  end

  def calculated_amounts
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def sql
    "SELECT sum(sums.weighted_budget) as weighted_budget, sum(ceil(sums.unweighted_budget::DOUBLE PRECISION)) as unweighted_budget, sums.product_id
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
                                               .select('sum(deal_product_budgets.budget::DOUBLE PRECISION) * stages.probability / 100 as weighted_budget,
                                                        sum(deal_product_budgets.budget::DOUBLE PRECISION) as unweighted_budget,
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