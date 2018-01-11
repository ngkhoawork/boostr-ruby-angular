class Api::AgencyDashboardsController < ApplicationController

  def spend_by_product
    data = FactTables::SpendByProductsQuery.new(revenue_sums_by_products, pipeline_sums_by_products).perform

    render json: data, each_serializer: AgencyDashboard::ProductSumsSerializer
  end

  def spend_by_advertisers
    data = FactTables::SpendByAdvertisersQuery.new(revenue_sums_by_accounts, pipeline_sums_by_accounts).perform

    render json: data, each_serializer: AgencyDashboard::AdvertiserSumsSerializer
  end

  def related_advertisers_without_spend
    data = AgencyDashboard::AdvertisersWithoutSpendSerializer.new(advertisers_without_spend).serializable_hash

    render json: data[:advertisers]
  end

  def spend_by_category
    data = AgencyDashboard::SpendByCategorySerializer.new(spend_by_category_data).serializable_hash

    render json: data[:categories]
  end

  def win_rate_by_category
    render json: win_rate_by_category_data, each_serializer: AgencyDashboard::WinRateByCategorySerializer
  end

  def contacts_and_related_advertisers
    render json: related_agencies_contacts, each_serializer: AgencyDashboard::ContactsAndRelatedAdvertisersSerializer
  end

  def activity_history
    activities = Activity.includes(:account_dimension, :activity_type).by_agency_ids(agencies_ids)

    render json: activities, each_serializer: AgencyDashboard::ActivityHistorySerializer
  end

  private

  def related_agencies_contacts
    ClientContact
        .includes(:account_dimension, contact: [:address, :latest_happened_activity])
        .where.not(client_id: agencies_ids)
        .where(contact_id: agency_contacts_ids)
  end

  def agency_contacts_ids
    ClientContact
        .where(client_id: agencies_ids)
        .pluck(:contact_id)
  end

  def win_rate_by_category_data
    WinRateByAdvertiserCategoryQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                             agencies_ids: agencies_ids)).perform
  end

  def revenue_sums_by_products
    FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery.new(filtered_revenues_by_products).perform
  end

  def pipeline_sums_by_products
    FactTables::AccountProductPipelineFacts::PipelineSumByProductQuery.new(filtered_pipelines_by_products).perform
  end

  def filtered_pipelines_by_products
    @_filtered_pipelines_by_products ||= FactTables::AccountProductPipelineFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).perform
  end

  def filtered_revenues_by_products
    @_filtered_revenues_by_products ||= FactTables::AccountProductRevenueFacts::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id)).perform
  end

  def revenue_sums_by_accounts
    FactTables::AccountProductRevenueFacts::RevenueSumByAccountQuery.new(filtered_revenues_by_accounts).perform
  end

  def pipeline_sums_by_accounts
    FactTables::AccountProductPipelineFacts::PipelineSumByAccountQuery.new(filtered_pipelines_by_accounts).perform
  end

  def filtered_revenues_by_accounts
    @_filtered_revenues_by_accounts ||= FactTables::AccountProductRevenueFacts::RevenueByRelatedAdvertisersQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                                                         advertisers_ids: related_advertisers_ids,
                                                                                                                                         agencies_ids: agencies_ids)).perform
  end

  def filtered_pipelines_by_accounts
    FactTables::AccountProductPipelineFacts::PipelineByRelatedAdvertisersQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                       advertisers_ids: related_advertisers_ids,
                                                                                                       agencies_ids: agencies_ids)).perform
  end

  def spend_by_category_data
    FactTables::AccountProductRevenueFacts::SpendByCategoryQuery.new(filtered_revenues_by_accounts).perform
  end

  def advertisers_without_spend
    FactTables::AdvertisersWithoutSpendQuery.new(filtered_open_pipelines,
                                                 advertiser_ids: related_advertisers_ids,
                                                 agencies_ids: agencies_ids,
                                                 start_date: filter_params[:start_date],
                                                 end_date: filter_params[:end_date]).perform
  end

  def agencies_ids
    @_agencies ||= AccountDimension.agencies_by_holding_company_or_agency_id(filter_params[:holding_company_id],
                                                                            filter_params[:account_ids],
                                                                            current_user_company_id).pluck(:id)
  end

  def filtered_open_pipelines
     FactTables::AccountRevenues::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                        advertiser_ids: related_advertisers_ids)).perform
  end

  def related_advertisers
    @_related_advertisers ||= AccountDimension.related_advertisers_to_agencies(agencies_ids)
  end

  def related_advertisers_ids
    @_related_advertisers_ids ||= related_advertisers.ids
  end

  def current_user_company_id
    current_user.company_id
  end

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_id, account_ids: [])
  end
end