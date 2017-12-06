class Api::PublisherDailyActualsController < ApplicationController
  respond_to :json

  def import
    PublisherDailyActualsImportWorker.perform_async(*import_params)

    render json: { message: processing_message }, status: :ok
  end

  private

  def import_params
    [current_user.company_id, file_params[:s3_file_path], file_params[:original_filename]]
  end

  def file_params
    params.require(:file).permit(:s3_file_path, :original_filename)
  end

  def processing_message
    'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)'
  end
end
