class Api::AgencyDashboardsController < ApplicationController

  def spend_by_product
    filtered_pipelines = FactTables::AccountProductPipelineFacts::FilteredQuery.new(filter_params).call
    filtered_revenues = FactTables::AccountProductRevenueFacts::FilteredQuery.new(filter_params).call
    pipeline_sums = FactTables::AccountProductPipelineFacts::PipelineSumQuery.new(filtered_pipelines).call
    revenue_sums = FactTables::AccountProductRevenueFacts::RevenueSumQuery.new(filtered_revenues).call
    render json: { revenue: revenue_sums, pipeline: pipeline_sums }
  end

  def by_agency

  end

  private

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_name, :account_name, :company_id)
  end

end