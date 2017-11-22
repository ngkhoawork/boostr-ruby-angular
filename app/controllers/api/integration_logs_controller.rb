class Api::IntegrationLogsController < ApplicationController
  include CleanPagination

  def index
    max_per_page = 100

    paginate current_user_integration_logs.count, max_per_page do |limit, offset|
      render json: current_user_integration_logs.limit(limit).offset(offset)
    end
  end

  def show
    render json: API::IntegrationLogs::Single.new(integration_log).to_hash
  end

  def resend_request
    if integration_log.dfp_query_type
      ManualDfpImportWorker.perform_async(dfp_api_configuration.id, integration_log.dfp_query_type)
    elsif integration_log.api_provider == 'asana_connect'
      AsanaConnectWorker.perform_async(integration_log.deal_id)
    else
      OperativeIntegrationWorker.perform_async(integration_log.deal_id)
    end
    render json: { message: 'triggered request resend' }
  end

  def latest_log
    latest_log = current_user_integration_logs.where(deal_id: params[:deal_id], object_name: 'deal').order('created_at DESC').first
    if latest_log
      render json: API::IntegrationLogs::Single.new(latest_log).to_hash
    else
      render json: { message: 'No logs found for this deal' }
    end
  end

  private

  def current_user_integration_logs
    current_user_company.integration_logs.errors_only(params[:errors_only])
  end

  def current_user_company
    @current_user_company ||= current_user.company
  end

  def dfp_api_configuration
    @dfp_api_configuration ||= DfpApiConfiguration.find_by(company: current_user_company)
  end

  def integration_log
    @integration_log = IntegrationLog.find(params[:id])
  end
end