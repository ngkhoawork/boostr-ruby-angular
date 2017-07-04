class Api::AgencyDashboardsController < ApplicationController

  def spend_by_product
    render json: { revenue: revenue_sums_by_products,
                   pipeline: pipeline_sums_by_products,
                   pipeline_totals: pipeline_total_by_product_by_time_dim,
                   revenue_totals: revenue_total_product_by_time_dim }
  end

  def spend_by_advertisers
    render json: { revenue: revenue_sums_by_accounts,
                   pipeline: pipeline_sums_by_accounts,
                   pipeline_totals: pipeline_total_by_account_by_time_dim,
                   revenue_totals: revenue_total_account_by_time_dim }
  end

  def advertisers_without_spend

  end

  private

  def revenue_total_product_by_time_dim
    revenue_sums_by_products.unscope(:group, :order, :select)
                            .group('time_dimensions.start_date, time_dimensions.end_date')
                            .select('time_dimensions.start_date, time_dimensions.end_date, sum(revenue_amount) as revenue_sum')
  end

  def pipeline_total_by_product_by_time_dim
    pipeline_sums_by_products.unscope(:group, :order, :select)
                             .group('time_dimensions.start_date, time_dimensions.end_date')
                             .select('time_dimensions.start_date, time_dimensions.end_date, sum(weighted_amount) as pipeline_sum')
  end

  def pipeline_total_by_account_by_time_dim
    pipeline_sums_by_accounts.unscope(:group, :order, :select)
                             .group('time_dimensions.start_date, time_dimensions.end_date')
                             .select('time_dimensions.start_date, time_dimensions.end_date, sum(weighted_amount) as pipeline_sum')
  end

  def revenue_total_account_by_time_dim
    revenue_sums_by_accounts.unscope(:group, :order, :select)
                            .group('time_dimensions.start_date, time_dimensions.end_date')
                            .select('time_dimensions.start_date, time_dimensions.end_date, sum(weighted_amount) as pipeline_sum')
  end

  def revenue_sums_by_products
    FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery.new(filtered_revenues_by_products).call
  end

  def pipeline_sums_by_products
    FactTables::AccountProductPipelineFacts::PipelineSumByProductQuery.new(filtered_pipelines_by_products).call
  end

  def filtered_pipelines_by_products
    FactTables::AccountProductPipelineFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).call
  end

  def filtered_revenues_by_products
    FactTables::AccountProductRevenueFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).call
  end

  def revenue_sums_by_accounts
    FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery.new(filtered_revenues_by_accounts).call
  end

  def filtered_revenues_by_accounts
    FactTables::AccountProductRevenueFacts::RevenueByRelatedAdvertisersQuery.new(start_date: filter_params[:start_date],
                                                                                 end_date: filter_params[:start_date],
                                                                                 company_id: current_user_company_id,
                                                                                 advertisers_ids: related_advertisers_ids).call
  end

  def pipeline_sums_by_accounts
    FactTables::AccountProductRevenueFacts::PipelineSumByProductQuery.new(filtered_pipelines_by_accounts).call
  end

  def filtered_pipelines_by_accounts
    FactTables::AccountProductRevenueFacts::PipelineByRelatedAdvertisersQuery.new(start_date: filter_params[:start_date],
                                                                                  end_date: filter_params[:start_date],
                                                                                  company_id: current_user_company_id,
                                                                                  advertisers_ids: related_advertisers_ids).call
  end

  def agency
    @agency ||= Client.find(filter_params[:account_id])
  end

  def related_advertisers_ids
    @related_advertisers_ids ||= agency.advertisers.pluck(:id)
  end

  def current_user_company_id
    current_user.company_id
  end

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_id, :account_id)
  end
end