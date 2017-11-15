class Api::PmpItemDailyActualsController < ApplicationController
  respond_to :json

  def index
    render json: ActiveModel::ArraySerializer.new(
      pmp_item_daily_actuals,
      each_serializer: Pmps::PmpItemDailyActualSerializer
    )
  end

  def import
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Csv::PmpItemDailyActual',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: 'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)'
      }, status: :ok
    end
  end

  private

  def pmp
    @_pmp ||= company.pmps.find(params[:pmp_id])
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= pmp.pmp_item_daily_actuals
  end

  def company
    @_company ||= current_user.company
  end
end
