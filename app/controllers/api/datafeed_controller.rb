class Api::DatafeedController < ApplicationController
  def import
    if datafeed_config&.start_job(job_type: job_type)
      render json: { message: 'Datafeed import has been triggered', status: 'ok' }
    else
      render json: { message: "Datafeed import can't be scheduled", status: 'error' }
    end
  end

  private

  def api_configuration_id
    params[:api_configuration_id]
  end

  def job_type
    params[:job_type]
  end

  def datafeed_config
    @datafeed_config ||= OperativeDatafeedConfiguration
      .joins(:datafeed_configuration_details)
      .where(company_id: current_user.company_id)
      .where(switched_on: true)
      .find_by(id: api_configuration_id)
  end
end
