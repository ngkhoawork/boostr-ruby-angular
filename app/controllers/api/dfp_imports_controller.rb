class Api::DfpImportsController < ApplicationController
  def import
    ManualDfpImportWorker.perform_async(api_configuration_id, report_type)
    render json: { message: report_type.capitalize + ' dfp import has been triggered' }
  end

  private

  def api_configuration_id
    params[:api_configuration_id]
  end

  def report_type
    params[:report_type]
  end
end
