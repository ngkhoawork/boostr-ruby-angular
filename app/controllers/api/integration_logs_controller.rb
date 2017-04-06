class Api::IntegrationLogsController < ApplicationController
  def index
    render json: API::IntegrationLogs::Collection.new(current_user_integration_logs).to_hash
  end

  def show
    render json: API::IntegrationLogs::Single.new(integration_log).to_hash
  end

  def resend_request
    OperativeIntegrationWorker.perform_async(integration_log.deal_id)
    render json: { message: 'triggered request resend' }
  end

  def latest_log
    latest_log = current_user_integration_logs.where(deal_id: params[:deal_id]).last
    if latest_log
      render json: API::IntegrationLogs::Single.new(latest_log).to_hash
    else
      render json: { message: 'No logs found for this deal' }
    end
  end

  private

  def current_user_integration_logs
    current_user_company.integration_logs
  end

  def current_user_company
    @current_user_company ||= current_user.company
  end

  def integration_log
    @integration_log = IntegrationLog.find(params[:id])
  end
end