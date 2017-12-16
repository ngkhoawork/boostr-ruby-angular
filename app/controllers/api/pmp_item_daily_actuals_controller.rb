class Api::PmpItemDailyActualsController < ApplicationController
  respond_to :json

  def index
    if params[:pmp_item_id].present? && params[:pmp_item_id] == 'all'
      render json: aggregated_pmp_daily_actuals.as_json
    elsif params[:pmp_item_id].present?
      render json: pmp_item_daily_actuals, each_serializer: Pmps::PmpItemDailyActualSerializer
    else
      render json: pmp_daily_actuals, each_serializer: Pmps::PmpItemDailyActualSerializer
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
      :product_id,
      :price,
      :revenue_loc,
      :impressions,
      :win_rate,
      :render_rate,
      :bids,
      :pmp_item_id
    )
  end

  def pmp
    @_pmp ||= company.pmps.find(params[:pmp_id])
  end

  def pmp_item
    @_pmp_item ||= pmp.pmp_items.find(params[:pmp_item_id])
  end

  def pmp_item_daily_actuals
    @_pmp_item_daily_actuals ||= pmp_item.pmp_item_daily_actuals.order(:date)
  end

  def aggregated_pmp_daily_actuals
    @_aggregated_pmp_daily_actuals ||= pmp.pmp_item_daily_actuals
      .select('date, sum(price) as price, sum(revenue_loc) as revenue_loc, sum(revenue) as revenue, sum(impressions) as impressions, sum(bids) as bids, avg(win_rate) as win_rate, avg(render_rate) as render_rate')
      .group('date')
  end

  def pmp_daily_actuals
    @_pmp_daily_actuals ||= pmp.pmp_item_daily_actuals
      .order(:pmp_item_id, :date)
      .limit(limit)
      .offset(offset)
  end

  def pmp_item_daily_actual
    @_pmp_item_daily_actual ||= pmp.pmp_item_daily_actuals.find(params[:id])
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
