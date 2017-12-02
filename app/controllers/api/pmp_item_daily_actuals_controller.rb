class Api::PmpItemDailyActualsController < ApplicationController
  respond_to :json

  def index
    respond_to do |format|
      format.json {
        if params[:pmp_item_id].present?
          render json: ActiveModel::ArraySerializer.new(
            pmp_item_daily_actuals
              .where(pmp_item_id: params[:pmp_item_id])
              .order(:date),
            each_serializer: Pmps::PmpItemDailyActualSerializer
          )          
        else
          render json: ActiveModel::ArraySerializer.new(
            pmp_item_daily_actuals.order(:pmp_item_id, :date)
              .limit(limit)
              .offset(offset),
            each_serializer: Pmps::PmpItemDailyActualSerializer
          )
        end
      }
    end
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

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end
