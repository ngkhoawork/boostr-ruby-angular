class Api::ActivePmpsController < ApplicationController
  respond_to :json, :csv

  def import_item
    SmartCsvImportWorker.perform_async(*import_params('Item'))
    render_response
  end

  def import_object
    SmartCsvImportWorker.perform_async(*import_params('Object'))
    render_response
  end

  private

  def import_params(name)
    [file_params[:s3_file_path],
     "Importers::ActivePmp#{name}ImportService",
     current_user.id,
     current_user.company_id,
     file_params[:original_filename]]
  end

  def file_params
    params.require(:file).permit(:s3_file_path, :original_filename)
  end

  def render_response
    render json: { message: I18n.t('csv.importer.response') }, status: :ok
  end

end
