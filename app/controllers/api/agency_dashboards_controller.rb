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
    activities = Activity.includes(:account_dimension, :activity_type).where(agency_id: agencies_ids).order('activities.happened_at DESC')
    max_per_page = 10
    # paginate activities.count, max_per_page do |limit, offset|
      render json: activities, each_serializer: AgencyDashboard::ActivityHistorySerializer
    # end
  end

  private

  def related_agencies_contacts
    @related_agencies_contacts ||= ClientContact.includes(:account_dimension, contact: [:address, :latest_happened_activity]).where.not(client_id: agencies_ids)
                                                .where(contact_id: agency_contacts_ids)
  end

  def agency_contacts_ids
    @agency_contact_ids ||= ClientContact.where(client_id: agencies_ids).pluck(:contact_id)
  end

  def win_rate_by_category_data
    WinRateByAdvertiserCategoryQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                             agencies_ids: agencies_ids)).call
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
                                                                                                                                        advertisers_ids: related_advertisers_with_agencies_in_ios,
                                                                                                                                        agencies_ids: agencies_ids)).call
  end

  def filtered_pipelines_by_accounts
    @filtered_pipelines_by_accounts ||= FactTables::AccountProductPipelineFacts::PipelineByRelatedAdvertisersQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                                                           advertisers_ids: related_advertisers_with_agencies_in_ios,
                                                                                                                                           agencies_ids: agencies_ids)).call
  end

  def spend_by_category_data
    FactTables::AccountProductRevenueFacts::SpendByCategoryQuery.new(filtered_revenues_by_accounts).call
  end

  def advertisers_without_spend
    FactTables::AdvertisersWithoutSpendQuery.new(filtered_open_pipelines,
                                                 advertiser_ids: related_advertisers_ids,
                                                 agencies_ids: agencies_ids).call
  end

  def agencies_ids
    @agencies ||= AccountDimension.agencies_by_holding_company_or_agency_id(filter_params[:holding_company_id],
                                                                            filter_params[:account_id],
                                                                            current_user_company_id).pluck(:id)
  end

  def filtered_open_pipelines
    @filtered_open_pipelines ||= FactTables::AccountRevenues::FilteredQuery.new(filter_params.merge(company_id: current_user_company_id,
                                                                                                    advertiser_ids: related_advertisers_ids)).call
  end

  def related_advertisers
    @related_advertisers_ids ||= AccountDimension.related_advertisers_to_agencies(agencies_ids)

  end

  def related_advertisers_ids
    related_advertisers.ids
  end

  def related_advertisers_with_agencies_in_ios
    related_advertisers.related_advertisers_with_agency_in_io.ids
  end

  def current_user_company_id
    current_user.company_id
  end

  def filter_params
    params.permit(:start_date, :end_date, :holding_company_id, :account_id)
  end
end