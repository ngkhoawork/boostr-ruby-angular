class Api::IntegrationLogsController < ApplicationController
  def index
    integration_logs = IntegrationLog.where(company_id: current_user.company_id)
    render json: API::IntegrationLogs::Collection.new(integration_logs).to_hash
  end

  def show
    render json: API::IntegrationLogs::Single.new(integration_log).to_hash
  end

  def resend_request
    OperativeIntegrationWorker.perform_async(integration_log.deal_id)
    render json: { message: 'triggered request resend' }
  end

  private

  def integration_log
    @integration_log = IntegrationLog.find_by(params[:id])
  end
end