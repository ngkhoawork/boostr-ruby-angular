module Calculators
  module Agreements
    class PipelineService < BaseService

      def perform
        return { weighted_pipeline: 0, unweighted_pipeline: 0 } if calculated_pipelines.blank?
        pipeline = calculated_pipelines.first
        { weighted_pipeline: pipeline.weighted_amount, unweighted_pipeline: pipeline.unweighted_amount }
      end

      private

      def calculated_pipelines
        @_calculated_pipelines ||= DealProductBudget.find_by_sql(sql)
      end

      def sql
        "SELECT
            sum(ceil(pipelines.weighted_budget::DOUBLE PRECISION)) as weighted_amount,
            sum(ceil(pipelines.unweighted_budget::DOUBLE PRECISION)) as unweighted_amount
         FROM (#{pipelines.to_sql}) AS pipelines
         GROUP by pipelines.spend_agreements_id"
      end

      def pipelines
        deal_product_budgets
            .group('spend_agreements_id, stages.probability')
            .select('sum(deal_product_budgets.budget::DOUBLE PRECISION) * stages.probability / 100 as weighted_budget,
                     sum(deal_product_budgets.budget::DOUBLE PRECISION) as unweighted_budget,
                     spend_agreements.id as spend_agreements_id')
      end

      def deal_product_budgets
        DealProductBudget
            .joins(deal_product: [:product, deal: [:stage, :spend_agreements]])
            .where(conditions,
                   spend_agreement_id: agreement_id,
                   start_date: agreement_start_date,
                   end_date: agreement_end_date)
      end

      def conditions
        'spend_agreements.id = :spend_agreement_id
         AND deal_products.open IS TRUE
         AND stages.open IS TRUE
         AND stages.probability != 100
         AND stages.probability != 0
         AND deal_product_budgets.end_date >= :start_date
         AND deal_product_budgets.start_date <= :end_date'
      end
    end
  end
end