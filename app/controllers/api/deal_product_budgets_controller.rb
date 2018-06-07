class Api::DealProductBudgetsController < ApplicationController
  respond_to :json

  before_filter :set_current_user, only: :create

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
    return unless params[:file].present?

    begin
      S3FileImportWorker.perform_async('Importers::DealProductBudgetsService',
                                    current_user.company_id,
                                    params[:file][:s3_file_path],
                                    params[:file][:original_filename])
      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    rescue Exception => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end
end
