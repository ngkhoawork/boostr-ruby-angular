class Api::DealProductBudgetsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.csv {
        require 'timeout'
        begin
          status = Timeout::timeout(120) {
            send_data DealProductBudget.to_csv(current_user.company_id), filename: "deal-prod-mon-budget-#{Date.today}.csv"
          }
        rescue Timeout::Error
          return
        end
      }
    end
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'DealProductBudget',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    end
  end
end
