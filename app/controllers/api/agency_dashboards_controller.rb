class Api::AgencyDashboardsController < ApplicationController

  def spend_by_product
    revenue = AgencyDashboard::SpendByProductSerializer.new(revenue_sums_by_products).serializable_hash
    pipeline = AgencyDashboard::SpendByProductSerializer.new(pipeline_sums_by_products).serializable_hash
    render json: revenue[:products] + pipeline[:products]
  end

  def spend_by_advertisers
    revenue = AgencyDashboard::SpendByAdvertiserSerializer.new(revenue_sums_by_accounts).serializable_hash
    pipeline = AgencyDashboard::SpendByAdvertiserSerializer.new(pipeline_sums_by_accounts).serializable_hash
    render json: revenue[:advertisers] + pipeline[:advertisers]
  end

  def related_advertisers_without_spend
    render json: AgencyDashboard::AdvertisersWithoutSpendSerializer.new(advertisers_without_spend).serializable_hash
  end

  def spend_by_category
    render json: AgencyDashboard::SpendByCategorySerializer.new(spend_by_category_data).serializable_hash
  end

  def win_rate_by_category
    render json: ActiveModel::ArraySerializer.new(win_rate_by_category_data,
                                                  each_serializer: AgencyDashboard::WinRateByCategorySerializer)

  end

  private

  def win_rate_by_category_data
    WinRateByAdvertizerCategoryQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                             advertisers_ids: related_advertisers_ids)).call
  end

  def revenue_sums_by_products
    FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery.new(filtered_revenues_by_products).call
  end

  def pipeline_sums_by_products
    FactTables::AccountProductPipelineFacts::PipelineSumByProductQuery.new(filtered_pipelines_by_products).call
  end

  def filtered_pipelines_by_products
    @filtered_pipelines_by_products ||= FactTables::AccountProductPipelineFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).call
  end

  def filtered_revenues_by_products
    @filtered_revenues_by_products ||= FactTables::AccountProductRevenueFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).call
  end

  def revenue_sums_by_accounts
    FactTables::AccountProductRevenueFacts::RevenueSumByAccountQuery.new(filtered_revenues_by_accounts).call
  end

  def pipeline_sums_by_accounts
    FactTables::AccountProductPipelineFacts::PipelineSumByAccountQuery.new(filtered_pipelines_by_accounts).call
  end

  def filtered_revenues_by_accounts
    @filtered_revenues_by_accounts ||= FactTables::AccountProductRevenueFacts::RevenueByRelatedAdvertisersQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                                                        advertisers_ids: related_advertisers_ids)).call
  end

  def filtered_pipelines_by_accounts
    @filtered_pipelines_by_accounts ||= FactTables::AccountProductPipelineFacts::PipelineByRelatedAdvertisersQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                                                           advertisers_ids: related_advertisers_ids)).call
  end

  def spend_by_category_data
    FactTables::AccountProductRevenueFacts::SpendByCategoryQuery.new(filtered_revenues_by_accounts).call
  end

  def advertisers_without_spend
    FactTables::AccountProductRevenueFacts::AdvertisersWithoutSpendQuery.new(filtered_revenues_by_accounts).call
  end

  def agencies
    #TODO: move to query object
    @agencies ||= AccountDimension.joins('LEFT JOIN holding_companies on holding_companies.id = account_dimensions.holding_company_id')
                                  .where('company_id = ? AND (account_dimensions.id = ? OR holding_company_id = ?)',
                                         current_user_company_id,
                                         filter_params[:account_id],
                                         filter_params[:holding_company_id])
  end

  def related_advertisers_ids
    @related_advertisers_ids ||= AccountDimension.joins(:advertisers)
                                                 .where('client_connections.agency_id in (?)', agencies.pluck(:id))
                                                 .pluck(:id)
  end

  def current_user_company_id
    current_user.company_id
  end

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_id, :account_id)
  end
end