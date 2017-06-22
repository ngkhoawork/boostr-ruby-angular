class Api::AgencyDashboardsController < ApplicationController

  def spend_by_product
    render json: { revenue: revenue_sums_by_products,
                   pipeline: pipeline_sums_by_products,
                   pipeline_totals: pipeline_total_by_time_dim,
                   revenue_totals: revenue_total_by_time_dim }
  end

  def by_agency

  end

  private

  def revenue_total_by_time_dim
    revenue_sums_by_products.unscope(:group, :order, :select)
                            .group('time_dimensions.start_date, time_dimensions.end_date')
                            .select('time_dimensions.start_date, time_dimensions.end_date, sum(revenue_amount) as revenue_sum')
  end

  def pipeline_total_by_time_dim
    pipeline_sums_by_products.unscope(:group, :order, :select)
                             .group('time_dimensions.start_date, time_dimensions.end_date')
                             .select('time_dimensions.start_date, time_dimensions.end_date, sum(weighted_amount) as pipeline_sum')
  end

  def revenue_sums_by_products
    FactTables::AccountProductRevenueFacts::RevenueSumQuery.new(filtered_revenues_by_products).call
  end

  def pipeline_sums_by_products
    FactTables::AccountProductPipelineFacts::PipelineSumQuery.new(filtered_pipelines_by_products).call
  end

  def filtered_pipelines_by_products
    FactTables::AccountProductPipelineFacts::FilteredQuery.new(filter_params).call
  end

  def filtered_revenues_by_products
    FactTables::AccountProductRevenueFacts::FilteredQuery.new(filter_params).call
  end

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_name, :account_name, :company_id)
  end
end