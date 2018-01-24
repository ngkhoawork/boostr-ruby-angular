class Api::PmpItemDailyActualsController < ApplicationController
  respond_to :json

  def index
    render json: pmp_actuals_serializer
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

  def update
    if pmp_item_daily_actual.update_attributes(pmp_item_daily_actual_params)
      render json: pmp_item_daily_actual, serializer: Pmps::PmpItemDailyActualSerializer
    else
      render json: { errors: pmp_item_daily_actual.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    pmp_item_daily_actual.destroy
    render nothing: true
  end

  private

  def pmp_item_daily_actual_params
    params.require(:pmp_item_daily_actual).permit(
      :date,
      :ad_unit,
      :price,
      :revenue_loc,
      :impressions,
      :win_rate,
      :render_rate,
      :bids,
      :pmp_item_id
    )
  end

  def filter_params
    params.permit(
      :pmp_item_id,
      :pmp_id
    )
  end

  def pmp_actuals_serializer
    if params[:pmp_item_id] == 'all'
      aggregated_actuals_serializer
    else
      filtered_actuals_serializer
    end
  end

  def aggregated_actuals
    PmpAggregatedActualsQuery.new(params).perform
  end

  def aggregated_actuals_serializer
    ActiveModel::ArraySerializer.new(
      aggregated_actuals,
      each_serializer: Pmps::PmpAggregatedActualSerializer
    )
  end

  def filtered_actuals
    data = PmpItemDailyActualsQuery.new(params).perform
    data = by_pages(data) if !params[:pmp_item_id]
    data
  end

  def filtered_actuals_serializer
    ActiveModel::ArraySerializer.new(
      filtered_actuals,
      each_serializer: Pmps::PmpItemDailyActualSerializer
    )
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= pmp.pmp_item_daily_actuals.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end
end
